vim.keymap.set("n", " ", "<nop>")
vim.g.mapleader = " "

require("user.options")
require("user.lazy")
require("user.keybindings")
require("user.autocmds")
