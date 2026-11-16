-- Local checkout so changes to the plugin are picked up without reinstalling.
local path = vim.fn.expand("~/Developer/review.nvim")
if vim.uv.fs_stat(path) then vim.opt.runtimepath:append(path) end
