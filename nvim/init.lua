require('plugins')
require('keybindings')

print('vim surround loaded ')
local g = vim.g
local fn = vim.fn
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
set.backupdir = '~/.local/share/nvim/backup/'

set.tabstop = 2
set.shiftwidth = 4
set.expandtab = true


local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

local lsp_installer = require('nvim-lsp-installer')
lsp_installer.on_server_ready(function(server)
    local opts = {}
    server:setup(opts)
end)

