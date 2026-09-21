local M = {}

local SEVERITIES = { "Hint", "Info", "Warn", "Error" }
local ALIGN = "%="
local SPACE = " "

local function setup_highlights()
  local base_highlight = vim.api.nvim_get_hl(0, { name = "StatusLine", link = false })
  local function highlight(name, source, extra)
    local fg = vim.api.nvim_get_hl(0, { name = source, link = false }).fg
    vim.api.nvim_set_hl(0, name, vim.tbl_extend("force", base_highlight, { fg = fg }, extra or {}))
  end

  highlight("StatusLineModified", "StatusLine", { italic = true })
  for _, severity in ipairs(SEVERITIES) do
    highlight("StatusLine" .. severity, "Diagnostic" .. severity)
  end
end

local function sanitize(text)
  return (text:gsub("%%", "%%%%"))
end

function M.render()
  local window = vim.g.statusline_winid or vim.api.nvim_get_current_win()
  local buffer = vim.api.nvim_win_get_buf(window)
  local file_path = vim.api.nvim_buf_get_name(buffer)
  local directory = file_path ~= "" and vim.fn.fnamemodify(file_path, ":.:h") .. "/ " or ""
  local file_name = vim.fn.fnamemodify(file_path, ":t")
  local modified = vim.bo[buffer].modified

  local icon = ""
  if file_name ~= "" then
    local extension = vim.fn.fnamemodify(file_path, ":e")
    icon = require("nvim-web-devicons").get_icon(file_name, extension, { default = true })
  end

  if file_name == "" then
    file_name = vim.bo[buffer].filetype ~= "" and vim.bo[buffer].filetype or "No Name"
  end

  local segments = {
    modified and "%#StatusLineModified#" or "%#StatusLine#",
    sanitize(directory),
    sanitize(icon),
    SPACE,
    sanitize(file_name),
    ALIGN
  }

  -- Dignostics
  local diagnostic_counts = vim.diagnostic.count(nil)
  for _, severity in ipairs(SEVERITIES) do
    local count = diagnostic_counts[vim.diagnostic.severity[severity:upper()]] or 0
    if count > 0 then
      local diagnostic_segment = string.format("%%#StatusLine%s#%s%%#StatusLine# %d ", severity, '●', count)
      table.insert(segments, diagnostic_segment)
    end
  end

  return table.concat(segments)
end

local group = vim.api.nvim_create_augroup("UserStatusline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", { group = group, callback = setup_highlights })
vim.api.nvim_create_autocmd("DiagnosticChanged", {
  group = group,
  callback = function() vim.cmd.redrawstatus() end,
})

setup_highlights()
vim.o.statusline = "%!v:lua.require'user.statusline'.render()"

return M
