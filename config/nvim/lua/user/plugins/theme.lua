function ToggleTheme()
  vim.o.background = vim.o.background == "dark" and "light" or "dark"
end

local function get_os_appearance()
  if vim.fn.has("mac") == 1 then
    vim.fn.system("defaults read -g AppleInterfaceStyle")
  else
    vim.fn.system("grep 'dark' " .. os.getenv("XDG_CACHE_HOME") .. "/os_theme")
  end
  return vim.v.shell_error == 1 and "light" or "dark"
end

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
      vim.o.background = get_os_appearance()
    end,
  },
}
