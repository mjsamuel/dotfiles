local function get_os_appearance()
  local os_theme_file = os.getenv("OS_APPEARANCE_FILE") or os.getenv("HOME") .. "/.cache/os_theme"
  vim.fn.system("grep 'dark' " .. os_theme_file)
  return vim.v.shell_error == 1 and "light" or "dark"
end
vim.o.background = get_os_appearance()

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
      })
      vim.cmd("colorscheme tokyonight")
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        highlight_groups = {
          StatusLine = { fg = "love", bg = "love", blend = 10 },
          StatusLineNC = { fg = "subtle", bg = "surface" },
        },
      })
    end,
  },
}
