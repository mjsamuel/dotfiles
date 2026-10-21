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

local function fingerprint(filename)
  local ok, disk = pcall(vim.fn.readfile, filename, "b")
  local buf = vim.fn.bufnr(filename)
  local lines = buf ~= -1 and vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].modified
    and vim.api.nvim_buf_get_lines(buf, 0, -1, false) or false
  return vim.fn.sha256(vim.json.encode({ disk = ok and disk or false, buffer = lines }))
end

local function hunk_key(item)
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
    if not hunks[id] then
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
    local count, total = 0, 0
    for id in pairs(hunks) do
      total = total + 1
      if reviewed[id] then count = count + 1 end
    end
    local complete = total > 0 and count == total
    if complete and was_complete == false then celebrate() end
    was_complete = complete
    if view.win:valid() then
      local label = ("%s | %d/%d hunks reviewed"):format(opts.label or "Review", count, total)
      vim.wo[view.win.win].winbar = label:gsub("%%", "%%%%")
        .. " | %#ReviewAdded#+" .. added .. "%* %#ReviewRemoved#−" .. removed .. "%*"
    end
  end

  local function validate(event)
    if not view.win:valid() then return end
    local filename_filter
    if event and (event.event == "TextChanged" or event.event == "TextChangedI"
      or event.event == "BufWritePost" or event.event == "BufEnter") then
      filename_filter = vim.api.nvim_buf_get_name(event.buf)
    end
    local changed, signatures = false, {}
    for id, filename in pairs(hunks) do
      if reviewed[id] and (not filename_filter or filename_filter == filename) then
        signatures[filename] = signatures[filename] or fingerprint(filename)
        if signatures[filename] ~= reviewed[id] then
          reviewed[id] = nil
          changed = true
        end
      end
    end
    if changed then render() end
    update()
  end

  view:map("<Space>", { desc = "Toggle hunk reviewed", action = function(_, ctx)
    local item = ctx.item
    if not item or not hunks[hunk_key(item)] then return end
    local id = hunk_key(item)
    if reviewed[id] then
      reviewed[id] = nil
      render()
      update()
      return
    end
    reviewed[id] = fingerprint(item.filename)
    local next_item
    local items = view:flatten()
    local complete = true
    for _, candidate in ipairs(items) do
      if candidate.filename == item.filename and not reviewed[hunk_key(candidate)] then
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
      if after_current and (not complete or candidate.filename ~= item.filename) then
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

  vim.keymap.set("x", "<Space>", function()
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

    local touched, signatures = {}, {}
    for _, item in ipairs(selected) do
      local id = hunk_key(item)
      touched[item.filename] = item
      if reviewed[id] then
        reviewed[id] = nil
      else
        signatures[item.filename] = signatures[item.filename] or fingerprint(item.filename)
        reviewed[id] = signatures[item.filename]
      end
    end
    -- Fold only after all selected hunks have been toggled.
    for _, item in ipairs(view:flatten()) do
      if not reviewed[hunk_key(item)] then touched[item.filename] = nil end
    end
    for _, item in pairs(touched) do
      local node = find_node(view.renderer.root_nodes, item)
      if node then view.renderer:fold(node, { action = "close" }) end
    end
    render(true)
    update()
  end, { buffer = view.win.buf, silent = true, desc = "Toggle selected hunks reviewed" })

  local group = vim.api.nvim_create_augroup("ReviewProgress", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "BufWritePost", "BufEnter",
    "FocusGained", "CursorHold", "FileChangedShellPost" }, {
    group = group,
    callback = validate,
  })
  validate()
  view:wait(update)
  return function(item) return reviewed[hunk_key(item)] ~= nil end
end

return M
