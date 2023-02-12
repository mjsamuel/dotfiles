local M = {
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
}

function ToggleTheme()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end

local function get_os_appearance()
  if vim.fn.has("mac") ~= 1 then
    return "dark"
  end

  vim.fn.system("defaults read -g AppleInterfaceStyle")
  return vim.v.shell_error == 1 and "light" or "dark"
end

function M.config()
  require("tokyonight").setup({
    style = "night",
    light_style = "day",
  })
  vim.cmd("colorscheme tokyonight")
  vim.o.background = get_os_appearance()
end

return M
