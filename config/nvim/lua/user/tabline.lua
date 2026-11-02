local M = {}

function M.render()
  local segments = {}
  local current = vim.api.nvim_get_current_tabpage()

  for index, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local buffer = vim.api.nvim_win_get_buf(vim.api.nvim_tabpage_get_win(tab))
    local icon, name = require("user.buffer_label")(buffer)
    local label = (icon .. " " .. name):gsub("%%", "%%%%")
    table.insert(segments, string.format("%%%dT%%#%s# %s ", index,
      tab == current and "TabLineSel" or "TabLine", label))
  end

  table.insert(segments, "%T%#TabLineFill#%=")
  return table.concat(segments)
end

vim.o.tabline = "%!v:lua.require'user.tabline'.render()"

return M
