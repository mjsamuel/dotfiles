local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

local function create_diagnostic_component(severity, icon, color)
  local function get_diagnostic_count(s)
    return #vim.diagnostic.get(nil, { severity = s })
  end

  return {
    function()
      return string.format("%s %s", icon, get_diagnostic_count(severity))
    end,
    padding = { left = 1, right = 0 },
    color = function()
      return get_diagnostic_count(severity) > 0 and color or nil
    end,
  }
end

function M.config()
  -- disable/hide the default statusline
  vim.opt.showmode = false
  vim.opt.laststatus = 0

  require("lualine").setup({
    options = {
      globalstatus = true,
      theme = "tokyonight",
      section_separators = "",
      component_separators = "",
      disabled_filetypes = { "alpha" },
    },
    sections = {
      lualine_a = { "mode" },
      lualine_b = {},
      lualine_c = {
        create_diagnostic_component("error", "", "DiagnosticError"),
        create_diagnostic_component("warn", "", "DiagnosticWarn"),
        create_diagnostic_component("hint", "", "DiagnosticHint"),
        { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
        { "filename" },
      },
      lualine_x = {
        -- word count for markdown and text files
        {
          function()
            local words = vim.fn.wordcount()["words"]
            return words .. " words"
          end,
          cond = function()
            local ft = vim.opt_local.filetype:get()
            local count = {
              text = true,
              markdown = true,
            }
            return count[ft] ~= nil
          end,
        },
        "branch",
      },
      lualine_y = {},
      lualine_z = {},
    },
  })
end

return M
