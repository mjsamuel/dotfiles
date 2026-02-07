vim.pack.add({ "https://github.com/rebelot/heirline.nvim" })

local ALIGN = { provider = "%=" }
local NULL = { provider = "" }
local SPACE = { provider = " " }

local setup_colors = function()
  local utils = require("heirline.utils")
  return {
    foreground = utils.get_highlight("StatusLine").fg,
    background = utils.get_highlight("StatusLine").bg,
    comment = utils.get_highlight("Comment").fg,
    diagnostic_error = utils.get_highlight("DiagnosticError").fg,
    diagnostic_warn = utils.get_highlight("DiagnosticWarn").fg,
    diagnostic_info = utils.get_highlight("DiagnosticInfo").fg,
    diagnostic_hint = utils.get_highlight("DiagnosticHint").fg,
  }
end

local segments = {}

local show_full_path = true
segments.file_info = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(0)
    self.filetype = vim.bo.filetype
  end,
  on_click = {
    callback = function(self, _, _, button)
      if button == "l" then
        show_full_path = not show_full_path
        vim.cmd("redrawstatus")
      elseif button == "r" then
        local file_path = vim.fn.fnamemodify(self.filename, ":p:.")
        vim.cmd('let @+="' .. file_path .. '"')
        vim.print("Copied filepath to system clipboard")
      end
    end,
    name = "handle_filename_click",
  },
  {
    -- file path
    flexible = 1,
    hl = { fg = "comment", bg = "background", italic = true },
    {
      provider = function(self)
        local file_path = vim.fn.fnamemodify(self.filename, ":.:h")
        return string.format("%s/ ", show_full_path and file_path or vim.fn.pathshorten(file_path))
      end,
    },
    NULL,
  },
  {
    -- file icon
    {
      init = function(self)
        if self.filename == "" then
          self.icon = ""
          return
        end

        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end,
      { provider = function(self) return self.icon end },
      SPACE,
    },
  },
  {
    -- file name
    provider = function(self)
      local file_name = vim.fn.fnamemodify(self.filename, ":t")
      if file_name ~= "" then
        return file_name
      elseif self.filetype ~= "" then
        return self.filetype
      else
        return "No Name"
      end
    end,
    hl = function() return { fg = "foreground", bg = "background", italic = vim.bo.modified } end,
  }
}

local function create_diagnostic_segment(severity)
  return {
    condition = function(self) return self.diagnostics[severity] > 0 end,
    {
      provider = function(self) return "" end,
      hl = function() return { fg = "diagnostic_" .. severity, bg = "background" } end,
    },
    SPACE,
    {
      provider = function(self) return self.diagnostics[severity] end,
    },
    SPACE,
  }
end
segments.diagnostics = {
  init = function(self)
    self.diagnostics = {
      error = #vim.diagnostic.get(nil, { severity = "error" }),
      warn = #vim.diagnostic.get(nil, { severity = "warn" }),
      hint = #vim.diagnostic.get(nil, { severity = "hint" }),
      info = #vim.diagnostic.get(nil, { severity = "info" }),
    }
  end,
  update = { "DiagnosticChanged", "BufEnter" },
  create_diagnostic_segment("hint"),
  create_diagnostic_segment("info"),
  create_diagnostic_segment("warn"),
  create_diagnostic_segment("error"),
}

local utils = require("heirline.utils")

vim.api.nvim_create_augroup("Heirline", { clear = true })
vim.api.nvim_create_autocmd("ColorScheme", {
  callback = function() utils.on_colorscheme(setup_colors) end,
  group = "Heirline",
})

require("heirline").setup({
  statusline = {
    SPACE,
    segments.file_info,
    ALIGN,
    segments.diagnostics,
    SPACE,
  },
  opts = { colors = setup_colors() },
})
