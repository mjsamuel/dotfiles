require("user.options")
require("user.plugins")
require("user.keybindings")

local autocmd = vim.api.nvim_create_autocmd

autocmd("FileType", {
	pattern = "alpha",
	callback = function()
		vim.opt.laststatus = 0
	end,
})

autocmd("BufUnload", {
  buffer = 0,
  callback = function()
    vim.opt.laststatus = 3
  end,
})

