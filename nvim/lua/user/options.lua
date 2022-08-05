local set = vim.opt

set.number = true
set.relativenumber = true

set.list = true
-- vim.cmd('set listchars=tab:→\\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»')
set.signcolumn = "yes:2"
set.hlsearch = false

set.mouse = "a"

set.scrolloff = 8
set.confirm = true

set.undofile = true
set.backup = true
set.backupdir = "/Users/matthewsamuel/.local/share/nvim/backup/"

set.tabstop = 2
set.shiftwidth = 4
set.expandtab = true

set.splitbelow = true
set.splitright = true

set.cursorline = true

set.termguicolors = true

vim.lsp.handlers["textDocument/references"] = require("telescope.builtin").lsp_references

set.laststatus = 3 -- global statusline
set.showmode = false

set.clipboard = "unnamedplus"

