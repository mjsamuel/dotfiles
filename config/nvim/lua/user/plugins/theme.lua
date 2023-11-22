local function get_os_appearance()
  local os_theme_file = os.getenv("OS_APPEARANCE_FILE") or os.getenv("HOME") .. "/.cache/os_theme"
  vim.fn.system("grep 'dark' " .. os_theme_file)
  return vim.v.shell_error == 1 and "light" or "dark"
end
vim.o.background = get_os_appearance()

return {
  {
    "rose-pine/neovim",
    lazy = false,
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        disable_background = true,
        disable_float_background = true,
      })
      vim.cmd("colorscheme rose-pine")
    end,
  },
}
