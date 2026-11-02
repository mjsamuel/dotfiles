local M = {}
local bindings = setmetatable({}, { __mode = "k" })

function M.map(view, key, opts)
  bindings[view] = bindings[view] or {}
  local mode = opts.mode or "n"
  bindings[view][mode .. key] = { key = key, mode = mode, desc = opts.desc }
  if mode == "x" then
    -- Visual actions must capture the selection before Trouble schedules them.
    view.win:map(key, function() opts.action(view) end, { mode = mode, desc = opts.desc, silent = true })
  else
    view:map(key, opts)
  end
end

function M.show(view)
  local entries = vim.tbl_values(bindings[view] or {})
  table.sort(entries, function(a, b)
    if a.key == b.key then return a.mode < b.mode end
    return a.key < b.key
  end)
  local lines = {}
  for _, entry in ipairs(entries) do
    lines[#lines + 1] = ("%s (%s)  %s"):format(entry.key, entry.mode == "x" and "visual" or "normal", entry.desc)
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = "q / Esc / ? to close"
  local width = vim.fn.strdisplaywidth(" Review keybindings ")
  for _, line in ipairs(lines) do width = math.max(width, vim.fn.strdisplaywidth(line)) end
  width = math.min(width + 2, math.max(1, vim.o.columns - 4))
  local available = vim.o.lines - vim.o.cmdheight
  local height = math.min(#lines, math.max(1, available - 4))
  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor", style = "minimal", border = "rounded",
    title = " Review keybindings ", title_pos = "center",
    width = width, height = height,
    row = math.max(0, math.floor((available - height - 2) / 2)),
    col = math.max(0, math.floor((vim.o.columns - width - 2) / 2)),
  })
  vim.wo[win].winbar = ""
  vim.wo[win].wrap = false
  local function close()
    if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
  end
  vim.keymap.set("n", { "q", "<Esc>", "?" }, close, { buffer = buf, silent = true })
end

function M.attach(view)
  M.map(view, "?", { desc = "Show review keybindings", action = function() M.show(view) end })
end

return M
