local set = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

set.completeopt = "menuone,noselect"
set.confirm = true -- confirm to save changes before exiting modified buffer
set.cursorline = true -- highlight current line
set.expandtab = true -- insert spaces when tab is pressed
set.fillchars = { eob = " " } -- hide tildes at end of file
set.formatoptions = "jcroqlnt" -- tcqj
set.hlsearch = false -- disable highlighting search term
set.ignorecase = true -- ignore case when searching
set.laststatus = 3 -- global statusline
set.list = true -- show invisible characters
set.listchars = { tab = "→ ", trail = "•", eol = "¬", extends = "»", precedes = "«" } -- how to show invisible characters
set.mouse = "a" -- enable mouse mode
set.number = true -- show line numbers
set.relativenumber = true -- relative line numbers
set.scrolloff = 4 -- padding on top and bottom of screen when scrolling
set.shiftround = true -- round indent to multiple of shiftwidth
set.shiftwidth = 4 -- number of spaces to use for autoindent
set.showmode = true
set.sidescrolloff = 8 -- Columns of context
set.signcolumn = "yes" -- always show sign column
set.smartcase = true -- dont ignore case with capitals
set.smartindent = true -- insert indents automatically
set.spelllang = { "en_au" } -- set preferred locale for trsttspelling
set.splitbelow = true -- put new windows below current
set.splitkeep = "screen"
set.splitright = true -- put new windows right of current
set.tabstop = 4 -- number of spaces to insert when tab is pressed
set.termguicolors = true -- true color support
set.timeoutlen = 500 -- time to wait for a mapped sequence to complete (in milliseconds)
set.undofile = true
set.wrap = false

vim.g.loaded_sql_completion = 0
vim.g.omni_sql_no_default_maps  = 1

vim.g.editorconfig = true
vim.g.markdown_recommended_style = 0
