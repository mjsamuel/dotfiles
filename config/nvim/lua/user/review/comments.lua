local M = {}
local ns = vim.api.nvim_create_namespace("review-comments")
local group = vim.api.nvim_create_augroup("ReviewComments", { clear = true })
local generation = 0
local files = {}
local attached = {}
local reviewed = {}

local function highlights()
  local comment = vim.api.nvim_get_hl(0, { name = "Comment", link = false })
  comment.italic = false
  vim.api.nvim_set_hl(0, "ReviewComment", comment)
end
highlights()
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = highlights })

local function thread_id(thread)
  return "review-comment:" .. (thread.id or thread.comments.nodes[1].url)
end

local function author(comment)
  return comment.author and comment.author ~= vim.NIL and comment.author.login or "deleted user"
end

local function changed()
  vim.api.nvim_exec_autocmds("User", { pattern = "ReviewCommentsChanged", modeline = false })
end

local function decode(result)
  if result.code ~= 0 then return nil, vim.trim(result.stderr or "") end
  local ok, value = pcall(vim.json.decode, result.stdout or "")
  if not ok then return nil, "invalid GitHub response" end
  if value.errors then return nil, vim.inspect(value.errors) end
  return value
end

-- Only anchor comments to lines unchanged from the revision they refer to.
local function local_line(hunks, line)
  local offset = 0
  for _, hunk in ipairs(hunks) do
    local start, count, _, new_count = unpack(hunk)
    if count == 0 then
      if start < line then offset = offset + new_count end
    elseif line < start then
      break
    elseif line < start + count then
      return nil
    else
      offset = offset + new_count - count
    end
  end
  return line + offset
end

local function anchor(file, thread, current, count, diffs)
  local original = thread.review_revision and file.sources[thread.review_revision]
  local line
  if original and current and type(thread.review_line) == "number" then
    local hunks = diffs[thread.review_revision]
    if not hunks then
      hunks = vim.diff(original, current, { result_type = "indices" })
      diffs[thread.review_revision] = hunks
    end
    line = local_line(hunks, thread.review_line)
    if line and (line < 1 or line > count) then line = nil end
  end
  local location = thread.isOutdated and " · outdated" or ""
  if not line then
    local reason = thread.diffSide == "LEFT" and "deleted line"
      or original and (thread.isOutdated and "commented line changed" or "line changed locally")
      or (thread.isOutdated and "original revision unavailable" or "PR head unavailable locally")
    local position = type(thread.originalLine) == "number" and thread.originalLine or thread.line
    location = location .. (" · %s (%s:%s)"):format(reason, thread.path, type(position) == "number" and position or "?")
  end
  return line, location
end

local function virtual_lines(thread, location)
  local lines = {
    { { ("╭ GitHub · %s%s"):format(thread.isResolved and "resolved" or "open", location), "ReviewComment" } },
  }
  for _, comment in ipairs(thread.comments.nodes) do
    lines[#lines + 1] = { { "│ ", "ReviewComment" }, { "@" .. author(comment), "ReviewComment" } }
    for _, body in ipairs(vim.split(comment.body:gsub("\r", ""), "\n", { plain = true })) do
      lines[#lines + 1] = { { "│ ", "ReviewComment" }, { body:gsub("\t", "    "), "ReviewComment" } }
    end
  end
  if thread.comments.totalCount > #thread.comments.nodes then
    lines[#lines + 1] = { { "│ More replies on GitHub: " .. thread.comments.nodes[1].url, "ReviewComment" } }
  end
  lines[#lines + 1] = { { "╰", "ReviewComment" } }
  return lines
end

local function render(buf)
  if not vim.api.nvim_buf_is_loaded(buf) then return end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  local file = files[vim.api.nvim_buf_get_name(buf)]
  if not file then return end
  local current = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n") .. "\n"
  local count = vim.api.nvim_buf_line_count(buf)
  local diffs = {}
  for _, thread in ipairs(file.threads) do
    if not reviewed[thread_id(thread)] then
      local line, location = anchor(file, thread, current, count, diffs)
      -- Virtual lines above row zero are hidden after quickfix jumps to the file top.
      vim.api.nvim_buf_set_extmark(buf, ns, (line or 1) - 1, 0, { virt_lines = virtual_lines(thread, location) })
    end
  end
  if not attached[buf] then
    attached[buf] = true
    vim.api.nvim_buf_attach(buf, false, {
      on_lines = function()
        vim.schedule(function()
          if vim.api.nvim_buf_is_valid(buf) then
            render(buf)
            changed()
          end
        end)
      end,
      on_detach = function() attached[buf] = nil end,
    })
  end
end

vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
  group = group,
  callback = function(event) render(event.buf) end,
})

function M.items()
  local items = {}
  for path, file in pairs(files) do
    local buf = vim.fn.bufnr(path)
    local lines
    if buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) then
      lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    else
      local ok, contents = pcall(vim.fn.readfile, path)
      if ok then lines = contents end
    end
    local current = lines and table.concat(lines, "\n") .. "\n"
    local diffs = {}
    for _, thread in ipairs(file.threads) do
      local line, location = anchor(file, thread, current, lines and #lines or 0, diffs)
      local first = thread.comments.nodes[1]
      local author = first.author and first.author ~= vim.NIL and first.author.login or "deleted user"
      items[#items + 1] = {
        id = thread_id(thread),
        filename = path,
        lnum = line or 1,
        review_comment = true,
        text = ("Comment · %s · @%s: %s%s"):format(thread.isResolved and "resolved" or "open",
          author, first.body:gsub("%s+", " "), location),
      }
    end
  end
  return items
end

function M.set_reviewed(state)
  reviewed = state
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do render(buf) end
end

function M.open(item)
  local file = item and files[item.filename]
  if not file then return end
  for _, thread in ipairs(file.threads) do
    if thread_id(thread) == item.id then
      local lines = {
        "# GitHub review · " .. (thread.isResolved and "resolved" or "open") .. (thread.isOutdated and " · outdated" or ""),
        "", thread.path, "",
      }
      for _, comment in ipairs(thread.comments.nodes) do
        vim.list_extend(lines, { "## @" .. author(comment), "" })
        vim.list_extend(lines, vim.split(comment.body:gsub("\r", ""), "\n", { plain = true }))
        lines[#lines + 1] = ""
      end
      lines[#lines + 1] = "[View full thread on GitHub](" .. thread.comments.nodes[1].url .. ")"
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = "wipe"
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
      vim.bo[buf].filetype = "markdown"
      pcall(vim.treesitter.start, buf, "markdown")
      vim.bo[buf].modifiable = false
      local width = math.min(100, math.max(1, vim.o.columns - 4))
      local height = math.min(#lines, math.max(1, math.floor((vim.o.lines - vim.o.cmdheight) * 0.7)))
      local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor", style = "minimal", border = "rounded", title = " Comment · select/yank normally · q to close ",
        width = width, height = height,
        row = math.max(0, math.floor((vim.o.lines - height) / 2) - 1),
        col = math.max(0, math.floor((vim.o.columns - width) / 2)),
      })
      vim.wo[win].wrap = true
      vim.wo[win].linebreak = true
      vim.wo[win].winbar = ""
      vim.keymap.set("n", { "q", "<Esc>" }, function()
        if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      end, { buffer = buf, silent = true })
      return buf
    end
  end
end

vim.api.nvim_create_user_command("ReviewComment", function()
  local filename = vim.api.nvim_buf_get_name(0)
  local items = vim.tbl_filter(function(item) return item.filename == filename end, M.items())
  if #items == 0 then
    vim.notify("No review comments in this file", vim.log.levels.INFO)
  elseif #items == 1 then
    M.open(items[1])
  else
    vim.ui.select(items, { prompt = "Review comment:", format_item = function(item) return item.text end }, M.open)
  end
end, { force = true })

function M.load(cwd, active)
  cwd = vim.uv.fs_realpath(cwd) or vim.fs.normalize(cwd)
  generation = generation + 1
  local id = generation
  files = {}
  reviewed = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1) end
  end
  changed()
  if vim.fn.executable("gh") ~= 1 then return end
  local function valid() return id == generation and active() end
  local function warn(err)
    if valid() then vim.notify("Review: could not load GitHub comments: " .. err, vim.log.levels.WARN) end
  end
  vim.system({ "gh", "pr", "view", "--json", "number,headRefOid,url" }, { cwd = cwd, text = true, timeout = 10000 }, vim.schedule_wrap(function(result)
    if not valid() then return end
    -- Reviewing a local branch without a PR is supported.
    if result.code ~= 0 then return end
    local pr, err = decode(result)
    if not pr then return warn(err) end
    local owner, repo = pr.url:match("https?://[^/]+/([^/]+)/([^/]+)/pull/%d+")
    if not owner then return warn("unrecognized PR URL") end
    local query = [[
      query($owner: String!, $repo: String!, $number: Int!, $endCursor: String) {
        repository(owner: $owner, name: $repo) {
          pullRequest(number: $number) {
            reviewThreads(first: 100, after: $endCursor) {
              pageInfo { hasNextPage endCursor }
              nodes {
                id path line originalLine diffSide isOutdated isResolved
                comments(first: 100) {
                  totalCount
                  nodes { body url author { login } originalCommit { oid } }
                }
              }
            }
          }
        }
      }
    ]]
    vim.system({ "gh", "api", "graphql", "--paginate", "--slurp", "-f", "query=" .. query,
      "-f", "owner=" .. owner, "-f", "repo=" .. repo, "-F", "number=" .. pr.number,
    }, { cwd = cwd, text = true, timeout = 30000 }, vim.schedule_wrap(function(response)
      if not valid() then return end
      local pages, query_err = decode(response)
      if not pages then return warn(query_err) end
      local pending = {}
      for _, page in ipairs(pages) do
        if page.errors then return warn(vim.inspect(page.errors)) end
        local repository = page.data and page.data.repository
        local pull = repository and repository ~= vim.NIL and repository.pullRequest
        if not pull or pull == vim.NIL then return warn("PR not found") end
        for _, thread in ipairs(pull.reviewThreads.nodes) do
          if #thread.comments.nodes > 0 then
            -- GitHub paths must never escape the repository.
            local path = vim.fs.normalize(cwd .. "/" .. thread.path)
            if vim.startswith(path, cwd .. "/") then
              pending[path] = pending[path] or { threads = {}, path = thread.path, sources = {} }
              if thread.diffSide == "RIGHT" then
                if thread.isOutdated then
                  local commit = thread.comments.nodes[1].originalCommit
                  thread.review_revision = commit and commit ~= vim.NIL and commit.oid or nil
                  thread.review_line = thread.originalLine
                else
                  thread.review_revision = pr.headRefOid
                  thread.review_line = thread.line
                end
              end
              table.insert(pending[path].threads, thread)
            end
          end
        end
      end
      for path, file in pairs(pending) do
        local revisions = {}
        for _, thread in ipairs(file.threads) do
          if thread.review_revision then revisions[thread.review_revision] = true end
        end
        local remaining = vim.tbl_count(revisions)
        local function publish()
          if not valid() then return end
          files[path] = file
          changed()
          for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_get_name(buf) == path then render(buf) end
          end
        end
        if remaining == 0 then publish() end
        for revision in pairs(revisions) do
          local function loaded(source)
            if not valid() then return end
            file.sources[revision] = source.code == 0 and source.stdout or false
            remaining = remaining - 1
            if remaining == 0 then publish() end
          end
          vim.system({ "git", "show", revision .. ":" .. file.path }, { cwd = cwd, text = true, timeout = 10000 }, vim.schedule_wrap(function(source)
            if not valid() then return end
            if source.code == 0 then return loaded(source) end
            -- Force-pushed review commits and a newer PR head may be absent locally.
            local api_path = vim.uri_encode(file.path, "rfc3986"):gsub("%%2F", "/")
            vim.system({ "gh", "api", "--method", "GET", "repos/" .. owner .. "/" .. repo .. "/contents/" .. api_path,
              "-f", "ref=" .. revision, "-H", "Accept: application/vnd.github.raw+json",
            }, { cwd = cwd, text = true, timeout = 10000 }, vim.schedule_wrap(loaded))
          end))
        end
      end
    end))
  end))
end

return M
