local M = {}
local sessions = {}

local function celebrate()
  if vim.fn.has("mac") ~= 1 then return end
  local installed = vim.fn.isdirectory("/Applications/Raycast.app") == 1
    or vim.fn.isdirectory(vim.fn.expand("~/Applications/Raycast.app")) == 1
  if installed then
    pcall(vim.system, { "open", "-g", "-b", "com.raycast.macos", "raycast://confetti" }, { text = true }, function() end)
  end
end

local function hunk_key(item)
  if item.review_comment then return item.id end
  return vim.json.encode({ item.filename, item.pos, item.item.text })
end

local function find_node(nodes, item)
  for _, node in ipairs(nodes) do
    if not node.group and node.item == item then return node end
    local found = find_node(node.children or {}, item)
    if found then return found end
  end
end

function M.attach(view, opts)
  local key = opts.session or opts.cwd or vim.fn.getcwd()
  sessions[key] = sessions[key] or {}
  local reviewed = sessions[key]
  local hunks = {}
  local added, removed = 0, 0
  for _, item in ipairs(view:flatten()) do
    local id = hunk_key(item)
    if not item.review_comment and not hunks[id] then
      -- Gitsigns quickfix headers omit the count when a range contains one line.
      local minus, plus = item.item.text:match("^%a+%s+%(%-%d+(,?%d*) %+%d+(,?%d*)%):")
      if minus then
        removed = removed + (tonumber(minus:sub(2)) or 1)
        added = added + (tonumber(plus:sub(2)) or 1)
      end
    end
    hunks[id] = item.filename
  end
  vim.api.nvim_set_hl(0, "ReviewAdded", { link = "Added", default = true })
  vim.api.nvim_set_hl(0, "ReviewRemoved", { link = "Removed", default = true })

  local function render(immediate)
    require("user.review.comments").set_reviewed(reviewed)
    -- Trouble caches leaf formatting, including the reviewed marker.
    for _, item in ipairs(view:flatten()) do item.cache:clear() end
    if immediate then
      -- Navigation needs the new row locations, not Trouble's throttled render.
      require("trouble.view").render(view)
    else
      view:render()
    end
  end

  local was_complete
  local function update()
    local count, total, comments, checked_comments = 0, 0, 0, 0
    hunks = {}
    for _, item in ipairs(view:flatten()) do
      local id = hunk_key(item)
      if not hunks[id] then
        if item.review_comment then
          comments = comments + 1
          if reviewed[id] then checked_comments = checked_comments + 1 end
        else
          total = total + 1
          if reviewed[id] then count = count + 1 end
        end
      end
      hunks[id] = item.filename
    end
    local complete = total + comments > 0 and count + checked_comments == total + comments
    if complete and was_complete == false then celebrate() end
    was_complete = complete
    if view.win:valid() then
      local label = ("%s | %d/%d hunks reviewed"):format(opts.label or "Review", count, total)
      if comments > 0 then label = label .. (" | %d/%d comments reviewed"):format(checked_comments, comments) end
      vim.wo[view.win.win].winbar = label:gsub("%%", "%%%%")
        .. " | %#ReviewAdded#+" .. added .. "%* %#ReviewRemoved#−" .. removed .. "%*"
    end
  end

  local keys = require("user.review.keys")
  keys.map(view, "<Space>", { desc = "Toggle item reviewed", action = function(_, ctx)
    local item = ctx.item
    if not item or not hunks[hunk_key(item)] then return end
    local id = hunk_key(item)
    if reviewed[id] then
      reviewed[id] = nil
      render()
      update()
      return
    end
    reviewed[id] = true
    local next_item
    local items = view:flatten()
    local complete = true
    for _, candidate in ipairs(items) do
      if candidate.filename == item.filename and hunks[hunk_key(candidate)] and not reviewed[hunk_key(candidate)] then
        complete = false
        break
      end
    end
    local current_node = find_node(view.renderer.root_nodes, item)
    if complete and current_node then
      view.renderer:fold(current_node, { action = "close" })
    end
    local after_current = false
    for _, candidate in ipairs(items) do
      if after_current and hunks[hunk_key(candidate)] and not reviewed[hunk_key(candidate)]
        and (not complete or candidate.filename ~= item.filename) then
        next_item = candidate
        break
      end
      if candidate == item then after_current = true end
    end
    if next_item then
      local node = find_node(view.renderer.root_nodes, next_item)
      if node then view.renderer:fold(node, { action = "open" }) end
    end
    render(true)
    update()
    if not next_item and not complete then return end
    vim.schedule(function()
      if not view.win:valid() then return end
      for row = 1, vim.api.nvim_buf_line_count(view.win.buf) do
        local at = view.renderer:at(row)
        local target = next_item and at.item == next_item and at.first_line
          or (not next_item and at.node and at.node.group and at.node.item
            and at.node.item.filename == item.filename)
        if target then
          vim.api.nvim_win_set_cursor(view.win.win, { row, 0 })
          if next_item then view:jump(next_item) end
          view.win:focus()
          return
        end
      end
    end)
  end })

  keys.map(view, "<Space>", { mode = "x", desc = "Toggle selected items reviewed", action = function()
    local anchor = vim.fn.line("v")
    local cursor = vim.api.nvim_win_get_cursor(view.win.win)[1]
    local selected, seen = {}, {}
    for row = math.min(anchor, cursor), math.max(anchor, cursor) do
      local item = view.renderer:at(row).item
      if item and hunks[hunk_key(item)] and not seen[item] then
        seen[item] = true
        selected[#selected + 1] = item
      end
    end
    vim.cmd("normal! " .. string.char(27))
    if #selected == 0 then return end

    local touched = {}
    for _, item in ipairs(selected) do
      local id = hunk_key(item)
      touched[item.filename] = item
      if reviewed[id] then
        reviewed[id] = nil
      else
        reviewed[id] = true
      end
    end
    -- Fold only after all selected items have been toggled.
    for _, item in ipairs(view:flatten()) do
      if hunks[hunk_key(item)] and not reviewed[hunk_key(item)] then touched[item.filename] = nil end
    end
    for _, item in pairs(touched) do
      local node = find_node(view.renderer.root_nodes, item)
      if node then view.renderer:fold(node, { action = "close" }) end
    end
    render(true)
    update()
  end })

  vim.api.nvim_create_autocmd("User", {
    group = vim.api.nvim_create_augroup("ReviewProgress" .. view.win.buf, { clear = true }),
    pattern = "ReviewCommentsChanged",
    callback = function()
      if not view.win:valid() or (opts.active and not opts.active()) then return true end
      local refresh = view:refresh()
      if refresh then refresh:next(update) end
    end,
  })
  require("user.review.comments").set_reviewed(reviewed)
  update()
  view:wait(update)
  return function(item) return reviewed[hunk_key(item)] ~= nil end
end

return M
