local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

local function get_diagnositc_count(severity)
  return #vim.diagnostic.get(nil, { severity = severity })
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
      lualine_b = {
        {
          function()
            return " "
              .. get_diagnositc_count("error")
              .. "  "
              .. get_diagnositc_count("warn")
              .. "  "
              .. get_diagnositc_count("hint")
          end,
          on_click = function()
            vim.cmd("TroubleToggle workspace_diagnostics")
          end,
        },
      },
      lualine_c = {
        { "filetype", icon_only = true, padding = { left = 1, right = 0 } },
        { "filename" },
      },
      lualine_x = {
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
