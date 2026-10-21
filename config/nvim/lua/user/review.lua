local M = {}
local request = 0

local function run(cwd, command)
  local thread = coroutine.running()
  vim.system(command, { cwd = cwd, text = true, timeout = 10000 }, vim.schedule_wrap(function(result)
    local ok, err = coroutine.resume(thread, result)
    if not ok then vim.notify(err, vim.log.levels.ERROR) end
  end))
  local result = coroutine.yield()
  if result.code ~= 0 then return nil, vim.trim(result.stderr or "") end
  return vim.split(vim.trim(result.stdout or ""), "\n", { plain = true })
end

local function git(cwd, ...)
  return run(cwd, { "git", ... })
end

local function choose_base(cwd, active, pick)
  local refs, err = git(cwd, "for-each-ref", "--no-contains=HEAD", "--format=%(refname:short)",
    "refs/heads", "refs/remotes/origin/HEAD")
  if not refs then return nil, err end
  local pr_base
  if vim.fn.executable("gh") == 1 then
    local result = run(cwd, { "gh", "pr", "view", "--json", "baseRefName", "--jq", ".baseRefName" })
    if result and result[1] ~= "" then
      pr_base = result[1]
      local remote = "origin/" .. pr_base
      if git(cwd, "rev-parse", "--verify", remote) then pr_base = remote end
      refs[#refs + 1] = pr_base
    end
  end
  local choices, seen = {}, {}
  for _, ref in ipairs(refs) do
    if not active() then return end
    if ref ~= "" and not seen[ref] then
      seen[ref] = true
      local count = git(cwd, "rev-list", "--count", ref .. "..HEAD")
      local distance = count and tonumber(count[1])
      if distance then choices[#choices + 1] = { ref = ref, distance = distance } end
    end
  end
  table.sort(choices, function(a, b)
    if a.distance == b.distance then return a.ref < b.ref end
    return a.distance < b.distance
  end)
  if #choices == 0 then return nil, "No candidate refs found; use :Review <base>" end
  if not active() then return end
  if not pick then return choices[1].ref end
  local thread = coroutine.running()
  vim.ui.select(choices, {
    prompt = "Review base:",
    format_item = function(item)
      return ("%s — %d commits ahead%s"):format(item.ref, item.distance,
        item.ref == pr_base and " [PR target]" or "")
    end,
  }, function(choice)
    vim.schedule(function()
      local ok, resume_err = coroutine.resume(thread, choice and choice.ref)
      if not ok then vim.notify(resume_err, vim.log.levels.ERROR) end
    end)
  end)
  return coroutine.yield()
end

---@param base string?
---@param opts table?
function M.open(base, opts)
  opts = opts or {}
  request = request + 1
  local id = request
  local review_win = opts.win or vim.api.nvim_get_current_win()
  local review_buf = vim.api.nvim_win_get_buf(review_win)
  local cwd = opts.cwd or vim.fn.getcwd()
  local ready, pr_result = false, nil

  local function active()
    return id == request and vim.api.nvim_win_is_valid(review_win)
  end

  local function show_pr()
    if not ready or not pr_result or not active() then return end
    if pr_result.code ~= 0 then
      vim.notify("Could not load PR details: " .. vim.trim(pr_result.stderr or ""), vim.log.levels.WARN)
      return
    end

    local buf = vim.fn.bufnr("^PR Details$")
    if buf == -1 then
      buf = vim.api.nvim_create_buf(true, false)
      vim.api.nvim_buf_set_name(buf, "PR Details")
    end
    -- Trouble only uses normal buffers as navigation targets.
    vim.bo[buf].buftype = ""
    vim.bo[buf].bufhidden = "hide"
    vim.bo[buf].swapfile = false
    vim.bo[buf].modifiable = true
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(vim.trim(pr_result.stdout or ""), "\n", { plain = true }))
    vim.bo[buf].modifiable = false
    vim.bo[buf].modified = false
    vim.api.nvim_win_set_buf(review_win, buf)
    vim.api.nvim_win_call(review_win, function()
      vim.bo[buf].filetype = "markdown"
    end)
    vim.keymap.set("n", "q", function()
      if vim.api.nvim_buf_is_valid(review_buf) then
        vim.api.nvim_win_set_buf(0, review_buf)
      else
        vim.cmd("enew")
      end
    end, { buffer = buf, silent = true })
  end

  if opts.details ~= false and vim.fn.executable("gh") == 1 then
    vim.system({ "gh", "pr", "view" }, { text = true, cwd = cwd }, vim.schedule_wrap(function(result)
      pr_result = result
      show_pr()
    end))
  elseif opts.details ~= false then
    pr_result = { code = 1, stderr = "gh is not installed" }
  end

  coroutine.wrap(function()
    local root, root_err = git(cwd, "rev-parse", "--show-toplevel")
    if not active() then return end
    if not root then
      vim.notify("Review: " .. root_err, vim.log.levels.ERROR)
      return
    end
    cwd = root[1]
    local ref, select_err
    if base and base ~= "" then ref = base else ref, select_err = choose_base(cwd, active, opts.pick_base) end
    if not active() then return end
    if not ref then
      if select_err then vim.notify("Review: " .. select_err, vim.log.levels.ERROR) end
      return
    end
    local merge_base, merge_err = git(cwd, "merge-base", "HEAD", ref)
    if not active() then return end
    if not merge_base then
      vim.notify("Review: could not determine fork point for '" .. ref .. "': " .. merge_err, vim.log.levels.ERROR)
      return
    end
    local label = "Review: " .. ref

    local gitsigns = require("gitsigns")
    vim.api.nvim_win_call(review_win, function()
      gitsigns.change_base(merge_base[1], true, function(err)
        if not active() then return end
        if err then
          vim.notify("Review: could not change comparison base: " .. tostring(err), vim.log.levels.ERROR)
          return
        end
        vim.api.nvim_win_call(review_win, function()
          gitsigns.setqflist("all", { open = false }, function(qf_err)
            if not active() then return end
            if qf_err then
              vim.notify("Review: could not load hunks: " .. tostring(qf_err), vim.log.levels.ERROR)
              return
            end
            require("user.review_list").open({
              win = review_win, cwd = cwd, active = active, label = label,
              session = cwd .. ":" .. merge_base[1], base = merge_base[1],
              change_base = function()
                M.open(nil, { pick_base = true, win = review_win, cwd = cwd, details = false })
              end,
            })
            if #vim.fn.getqflist() == 0 then vim.notify("Review: no text hunks found") end
            vim.notify(label)
            ready = true
            show_pr()
          end)
        end)
      end)
    end)
  end)()
end

return M
