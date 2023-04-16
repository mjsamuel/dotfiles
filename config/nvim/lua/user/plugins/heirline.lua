local M = {
  "rebelot/heirline.nvim",
  event = "VeryLazy",
}

M.config = function()
  local utils = require("heirline.utils")
  local conditions = require("heirline.conditions")

  -- setup colors
  local function setup_colors()
    return {
      foreground = utils.get_highlight("StatusLine").fg,
      background = utils.get_highlight("StatusLine").bg,
      comment = utils.get_highlight("Comment").fg,
      diagnostic_error = utils.get_highlight("DiagnosticError").fg,
      diagnostic_warn = utils.get_highlight("DiagnosticWarn").fg,
      diagnostic_info = utils.get_highlight("DiagnosticInfo").fg,
      diagnostic_hint = utils.get_highlight("DiagnosticHint").fg,
      mode_normal = utils.get_highlight("MiniStatuslineModeNormal").bg,
      mode_insert = utils.get_highlight("MiniStatuslineModeInsert").bg,
      mode_visual = utils.get_highlight("MiniStatuslineModeVisual").bg,
      mode_command = utils.get_highlight("MiniStatuslineModeCommand").bg,
      mode_replace = utils.get_highlight("MiniStatuslineModeReplace").bg,
      mode_other = utils.get_highlight("MiniStatuslineModeOther").bg,
    }
  end

  vim.api.nvim_create_augroup("Heirline", { clear = true })
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      utils.on_colorscheme(setup_colors)
    end,
    group = "Heirline",
  })

  -- Segments
  local Align = { provider = "%=" }
  local Space = { provider = " " }

  local ModeSegment = {
    init = function(self)
      self.mode = vim.fn.mode(1)
    end,
    static = {
      mode_names = {
        n = "NORMAL",
        no = "O-PENDING",
        nov = "O-PENDING",
        noV = "O-PENDING",
        ["no\22"] = "O-PENDING",
        niI = "NORMAL",
        niR = "NORMAL",
        niV = "NORMAL",
        nt = "NORMAL",
        v = "VISUAL",
        vs = "VISUAL",
        V = "V-LINE",
        Vs = "V-LINE",
        ["\22"] = "^V",
        ["\22s"] = "^V",
        s = "SUBSTITUTE",
        S = "S-LINE",
        ["\19"] = "^S",
        i = "INSERT",
        ic = "INSERT",
        ix = "INSERT",
        R = "REPLACE",
        Rc = "REPLACE",
        Rx = "REPLACE",
        Rv = "REPLACE",
        Rvc = "REPLACE",
        Rvx = "REPLACE",
        c = "COMMAND",
        cv = "COMMAND",
        r = "...",
        rm = "M",
        ["r?"] = "?",
        ["!"] = "!",
        t = "T",
      },
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
    Space,
    {
      provider = function(self)
        return self.mode_names[self.mode]
      end,
      hl = function(self)
        local mode = self.mode:sub(1, 1) -- get only the first mode character
        return { fg = self.mode_colors[mode], bg = "background" }
      end,
    },
    update = {
      "ModeChanged",
      pattern = "*:*",
      callback = vim.schedule_wrap(function()
        vim.cmd("redrawstatus")
      end),
    },
  }

  FileNameSegment = utils.insert(
    {
      init = function(self)
        self.filename = vim.api.nvim_buf_get_name(0)
        self.filetype = vim.bo.filetype
      end,
    },
    { -- file path
      condition = function (self)
        return self.filename ~= ""
      end,
      provider = function(self)
        local filename = vim.fn.fnamemodify(self.filename, ":.:h")
        if not conditions.width_percent_below(#filename, 0.3) then
          filename = vim.fn.pathshorten(filename)
        end
        return filename .. "/ "
      end,
      hl = function()
        return { fg = "comment", bg = "background", italic = true }
      end,
    },
    { -- file icon
      init = function(self)
        local filename = self.filename
        local extension = vim.fn.fnamemodify(filename, ":e")
        self.icon, self.icon_color =
          require("nvim-web-devicons").get_icon_color(filename, extension, { default = true })
      end,
      provider = function(self)
        return self.icon and self.icon
      end,
      hl = function(self)
        return { fg = self.icon_color, bg = "background" }
      end,
    },
    Space,
    { -- file name
      provider = function(self)
        return self.filename ~= "" and vim.fn.fnamemodify(self.filename, ":t") or self.filetype
      end,
      hl = function(self)
        if vim.bo.modified and self.filename ~= "" then
          return { fg = "foreground", bg = "background", italic = true }
        else
          return "StatusLine"
        end
      end,
    },
    { provider = "%<" } -- this means that the statusline is cut here when there's not enough space
  )

  local DiagnosticsSegment = {
    condition = function()
        return vim.api.nvim_buf_get_name(0) ~= ""
    end,
    static = {
      error_icon = "",
      warn_icon = "",
      info_icon = "",
      hint_icon = "",
      default_hl = { fg = "comment", bg = "background", italic = true },
    },
    init = function(self)
      self.errors = #vim.diagnostic.get(nil, { severity = "error" })
      self.warnings = #vim.diagnostic.get(nil, { severity = "warn" })
      self.hints = #vim.diagnostic.get(nil, { severity = "hint" })
      self.info = #vim.diagnostic.get(nil, { severity = "info" })
    end,
    update = { "DiagnosticChanged", "BufEnter" },
    {
      provider = function(self)
        return self.errors > 0 and " " .. self.error_icon .. " " .. self.errors
      end,
      hl = function()
        return { fg = "diagnostic_error", bg = "background" }
      end,
    },
    {
      provider = function(self)
        return self.warnings > 0 and " " .. self.warn_icon .. " " .. self.warnings
      end,
      hl = function()
        return { fg = "diagnostic_warn", bg = "background" }
      end,
    },
    {
      provider = function(self)
        return self.info > 0 and " " .. self.info_icon .. " " .. self.info
      end,
      hl = function()
        return { fg = "diagnostic_info", bg = "background" }
      end,
    },
    {
      provider = function(self)
        return self.hints > 0 and " " .. self.hint_icon .. " " .. self.hints
      end,
      hl = function()
        return { fg = "diagnostic_hint", bg = "background" }
      end,
    },
  }

  local WordCountSegment = {
    condition = function()
      local ft = vim.opt_local.filetype:get()
      local count = {
        text = true,
        markdown = true,
      }
      return count[ft] ~= nil
    end,
    init = function(self)
      self.word_count = vim.fn.wordcount()["words"]
    end,
    {
      provider = function(self)
        return self.word_count .. " words"
      end,
    },
    hl = { fg = "comment", bg = "background" },
  }

  local GitSegment = {
    condition = conditions.is_git_repo,
    init = function(self)
      self.status_dict = vim.b.gitsigns_status_dict
      self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
    end,
    {
      provider = function(self)
        return " " .. self.status_dict.head
      end,
    },
    hl = { fg = "comment", bg = "background" },
  }

  require("heirline").setup({
    statusline = {
      ModeSegment,
      Space,
      FileNameSegment,
      DiagnosticsSegment,
      Align,
      WordCountSegment,
      Space,
      GitSegment,
      Space,
    },
    opts = { colors = setup_colors() },
  })
end

return M
