local set = vim.opt

set.number = true
set.relativenumber = true

set.list = true
vim.cmd("set listchars=tab:→\\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»")
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
set.smartindent = true

set.splitbelow = true
set.splitright = true

set.cursorline = true

set.termguicolors = true

set.laststatus = 3
set.showmode = false

set.fillchars = { eob = " " }

set.lazyredraw = true

set.wrap = false

set.ignorecase = true
set.smartcase = true

set.spelllang = "en_au"
