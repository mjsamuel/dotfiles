local M = {
  "nvim-lualine/lualine.nvim",
  event = "VeryLazy",
}

function M.config()
  -- disable/hide the default statusline
  vim.opt.showmode = false
  vim.opt.laststatus = 0

  local navic = require("nvim-navic")
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
      lualine_b = { "branch" },
      lualine_c = {
        { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
        {
          "filename",
          symbols = { modified = "", readonly = "", unnamed = "" },
          separator = "",
        },
        { navic.get_location, cond = navic.is_available },
      },
    },
  })
end

return M
