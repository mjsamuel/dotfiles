local set = vim.opt

set.number = true
set.relativenumber = true

set.list = true
vim.cmd('set listchars=tab:→\\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»')
set.signcolumn = "yes:1"
set.hlsearch = false

set.mouse = "a"

set.scrolloff = 8
set.confirm = true

set.undofile = true
set.backup = true
set.backupdir = os.getenv("HOME") .. "/.local/share/nvim/backup/"

set.tabstop = 2
set.shiftwidth = 4
set.expandtab = true

set.splitbelow = true
set.splitright = true

set.cursorline = true

set.termguicolors = true

set.laststatus = 3
set.showmode = false

set.clipboard = "unnamedplus"

set.fillchars = { eob = " " }

set.lazyredraw = true

set.wrap = false

-- disable default plugins
local disabled_built_ins = {
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "gzip",
    "zip",
    "zipPlugin",
    "tar",
    "tarPlugin",
    "getscript",
    "getscriptPlugin",
    "vimball",
    "vimballPlugin",
    "2html_plugin",
    "logipat",
    "rrhelper",
    "spellfile_plugin",
    "matchit"
}

for _, plugin in pairs(disabled_built_ins) do
    vim.g["loaded_" .. plugin] = 1
end
