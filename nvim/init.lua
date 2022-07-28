require('plugins')
require('keybindings')

local set = vim.opt 

set.number = true
set.relativenumber = true

set.list = true
vim.cmd('set listchars=tab:→\\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»')
set.signcolumn='yes:2'
set.hlsearch = false

set.mouse = 'a'

set.scrolloff = 8
set.confirm = true

set.undofile = true
set.backup = true

set.tabstop = 2
set.shiftwidth = 4
set.expandtab = true

local lsp_installer = require('nvim-lsp-installer')
lsp_installer.on_server_ready(function(server)
    local opts = {}
    server:setup(opts)
end)

