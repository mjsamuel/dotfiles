local M = {}
local generated = {}
local request = 0

local config = require("trouble.config")
config.get("quickfix")
config.defaults({ modes = { review = { mode = "quickfix" } } })

local function generated_files(cwd, callback)
  local files = {}
  for _, item in ipairs(vim.fn.getqflist()) do
    local filename = vim.api.nvim_buf_get_name(item.bufnr)
    if filename ~= "" then files[filename] = true end
  end
  local paths = vim.tbl_keys(files)
  if #paths == 0 then
    vim.schedule(function() callback({}) end)
    return
  end

  vim.system({ "git", "check-attr", "-z", "--stdin", "linguist-generated" }, {
    cwd = cwd,
    stdin = table.concat(paths, "\0") .. "\0",
  }, vim.schedule_wrap(function(result)
    local files = {}
    if result.code == 0 then
      local attributes = vim.split(result.stdout or "", "\0", { plain = true })
      for i = 1, #attributes - 2, 3 do
        local value = attributes[i + 2]
        if value == "set" or value == "true" then
          files[attributes[i]] = true
        end
      end
    end
    if result.code ~= 0 then
      vim.notify("Review: could not classify generated files: " .. vim.trim(result.stderr or ""), vim.log.levels.WARN)
    end
    callback(files)
  end))
end

local function sort_quickfix()
  local list = vim.fn.getqflist({ items = 1, idx = 0 })
  if #list.items == 0 then return end

  local current = list.items[list.idx]
  local regular, generated_items = {}, {}
  for _, item in ipairs(list.items) do
    local filename = vim.api.nvim_buf_get_name(item.bufnr)
    local target = generated[filename] and generated_items or regular
    target[#target + 1] = item
  end
  vim.list_extend(regular, generated_items)

  local idx = 1
  for i, item in ipairs(regular) do
    if item == current then idx = i end
  end
  vim.fn.setqflist({}, "r", { items = regular, idx = idx })
end

local function open_list(files, opts)
  generated = files
  local is_reviewed = function() return false end
  sort_quickfix()
  vim.api.nvim_set_hl(0, "ReviewGenerated", { link = "Comment", default = true })

  local function formatter(template, hunk)
    return function(ctx)
      local prefix = hunk and (is_reviewed(ctx.item) and "[✓] " or "[ ] ") or ""
      local segments = require("trouble.format").format(prefix .. template, ctx)
      if generated[ctx.item.filename] then
        for _, segment in ipairs(segments) do
          segment.hl = "ReviewGenerated"
        end
      end
      return segments
    end
  end

  local view = require("trouble").open({
    mode = "review",
    groups = { { "filename", format = "{review_file}" } },
    format = "{review_hunk}",
    sort = { "generated", "severity", "filename", "pos", "message" },
    sorters = {
      generated = function(item) return generated[item.filename] and 1 or 0 end,
    },
    formatters = {
      review_file = formatter("{file_icon}{filename} {count}"),
      review_hunk = formatter("{text:ts} {pos}", true),
    },
  })
  if view then
    view:wait(function()
      if opts.change_base then
        view:map("b", { desc = "Change review base", action = opts.change_base })
      end
      is_reviewed = require("user.review_progress").attach(view, opts)
      for _, item in ipairs(view:flatten()) do item.cache:clear() end
      for _, node in ipairs(view.renderer.root_nodes) do
        if node.item and generated[node.item.filename] then
          view.renderer:fold(node, { action = "close" })
        end
      end
      view:render()
    end)
  end
  return view
end

function M.open(opts)
  opts = opts or {}
  request = request + 1
  local id = request
  local win = opts.win or vim.api.nvim_get_current_win()
  local list = vim.fn.getqflist({ id = 0, changedtick = 0 })
  generated_files(opts.cwd or vim.fn.getcwd(), function(files)
    if id ~= request or not vim.api.nvim_win_is_valid(win) then return end
    if opts.active and not opts.active() then return end
    local current = vim.fn.getqflist({ id = 0, changedtick = 0 })
    if current.id ~= list.id or current.changedtick ~= list.changedtick then return end
    require("user.review_preload").start(function()
      return id == request and vim.api.nvim_win_is_valid(win) and (not opts.active or opts.active())
    end, opts.base)
    vim.api.nvim_win_call(win, function() open_list(files, opts) end)
  end)
end

return M
