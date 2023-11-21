local M = {
  "rebelot/heirline.nvim",
  event = "VeryLazy",
}

local ALIGN = { provider = "%=" }
local NULL = { provider = "" }
local SPACE = { provider = " " }

local setup_colors = function()
  local utils = require("heirline.utils")
  return {
    foreground = utils.get_highlight("StatusLine").fg,
    background = utils.get_highlight("StatusLine").bg,
    comment = utils.get_highlight("Comment").fg,
    mode_normal = utils.get_highlight("StatuslineModeNormal").bg,
    mode_insert = utils.get_highlight("StatuslineModeInsert").bg,
    mode_visual = utils.get_highlight("StatuslineModeVisual").bg,
    mode_command = utils.get_highlight("StatuslineModeCommand").bg,
    mode_replace = utils.get_highlight("StatuslineModeReplace").bg,
    mode_other = utils.get_highlight("StatuslineModeOther").bg,
  }
end

local segments = {}

segments.mode = function()
  return {
    init = function(self) self.mode = vim.fn.mode(1) end,
    static = {
      mode_colors = {
        n = "mode_normal",
        i = "mode_insert",
        v = "mode_visual",
        V = "mode_visual",
        ["\22"] = "mode_other",
        c = "mode_command",
        s = "mode_other",
        S = "mode_other",
        ["\19"] = "mode_other",
        R = "mode_replace",
        r = "mode_replace",
        ["!"] = "mode_other",
        t = "mode_other",
      },
    },
    provider = function() return "▊" end,
    hl = function(self)
      local mode = self.mode:sub(1, 1) -- get only the first mode character
      return { fg = self.mode_colors[mode], bg = "background" }
    end,
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function() vim.cmd("redrawstatus") end),
    },
  }
end

local show_full_path = false
segments.file_info = function()
  local utils = require("heirline.utils")
  return utils.insert({
    init = function(self)
      self.filename = vim.api.nvim_buf_get_name(0)
      self.filetype = vim.bo.filetype
    end,
    on_click = {
      callback = function()
        show_full_path = not show_full_path
        vim.cmd("redrawstatus")
      end,
      name = "toggle_full_path",
    },
  }, {
    -- file path
    condition = function() return show_full_path end,
    flexible = 1,
    hl = { fg = "comment", bg = "background", italic = true },
    {
      provider = function(self)
        local file_path = vim.fn.fnamemodify(self.filename, ":.:h")
        return string.format("%s/ ", file_path)
      end,
    },
    {
      provider = function(self)
        local file_path_short = vim.fn.fnamemodify(self.filename, ":.:h")
        return string.format("%s/ ", vim.fn.pathshorten(file_path_short))
      end,
    },
    NULL,
  }, {
    -- file icon
    {
      condition = function(self) return self.filename ~= "" end,
      init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon = require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end,
      { provider = function(self) return self.icon end },
      SPACE,
    },
    {
      condition = function(self) return self.filename == "" end,
      { provider = function() return "" end },
      SPACE,
    },
  }, {
    -- file name
    provider = function(self)
      local file_name = vim.fn.fnamemodify(self.filename, ":t")
      if file_name ~= "" then
        return file_name
      elseif self.filetype ~= "" then
        return self.filetype
      else
        return "[No Name]"
      end
    end,
    hl = function() return { fg = "foreground", bg = "background", italic = vim.bo.modified } end,
  })
end

segments.diagnostics = function()
  local function create_diagnostic_segment(severity)
    return {
      condition = function(self) return self.diagnostics[severity] > 0 end,
      provider = function(self)
        local icon = self.icons[severity:gsub("^%l", string.upper)]
        local num_errors = self.diagnostics[severity]
        return string.format("%s %d ", icon, num_errors)
      end,
      hl = { fg = "comment", bg = "background", italic = true },
    }
  end

  return {
    static = {
      icons = require("user.misc.opts").signs,
    },
    init = function(self)
      self.diagnostics = {
        error = #vim.diagnostic.get(nil, { severity = "error" }),
        warn = #vim.diagnostic.get(nil, { severity = "warn" }),
        hint = #vim.diagnostic.get(nil, { severity = "hint" }),
        info = #vim.diagnostic.get(nil, { severity = "info" }),
      }
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    create_diagnostic_segment("error"),
    create_diagnostic_segment("warn"),
    create_diagnostic_segment("info"),
    create_diagnostic_segment("hint"),
  }
end

segments.git_branch = function()
  local conditions = require("heirline.conditions")
  return {
    condition = conditions.is_git_repo,
    init = function(self) self.status_dict = vim.b.gitsigns_status_dict end,
    provider = function(self) return " " .. self.status_dict.head end,
  }
end

M.config = function()
  local utils = require("heirline.utils")

  vim.api.nvim_create_augroup("Heirline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function() utils.on_colorscheme(setup_colors) end,
    group = "Heirline",
  })

  require("heirline").setup({
    statusline = {
      segments.mode(),
      SPACE,
      segments.file_info(),
      SPACE,
      segments.diagnostics(),
      ALIGN,
      segments.git_branch(),
      SPACE,
    },
    opts = { colors = setup_colors() },
  })
end

return M
