set expandtab
"set shiftwidth=4
"set tabstop=4
set hidden
set signcolumn=yes:2
set relativenumber
set number
set termguicolors
set undofile
set title
set ignorecase
set smartcase
set wildmode=longest:full,full
set nowrap
set list
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»
set mouse=a
set scrolloff=8
set sidescrolloff=8
set nojoinspaces
set splitright
set clipboard=unnamedplus
set confirm
set exrc
set backup
set backupdir=~/.local/share/nvim/backup//
set updatetime=300 " Reduce time for highlighting other references
set redrawtime=10000 " Allow more time for loading syntax on large files
set colorcolumn=80
set nohlsearch

nnoremap ; :
let mapleader = "\<space>"
nmap <leader>ve :edit ~/.config/nvim/init.vim<cr>
nmap <leader>vc :edit ~/.config/nvim/coc-settings.json<cr>
nmap <leader>vr :source ~/.config/nvim/init.vim<cr>
nnoremap v <c-v>

" close all buffers except for the currently focused file
nmap <leader>w :%bd\|e#\|bd#<cr>

" Allow gf to open non-existent files
map gf :edit <cfile><cr>

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(data_dir . '/plugins')
  source ~/.config/nvim/plugins/airline.vim
  source ~/.config/nvim/plugins/coc.vim
  source ~/.config/nvim/plugins/commentary.vim
  source ~/.config/nvim/plugins/copilot.vim
  source ~/.config/nvim/plugins/editorconfig.vim
  source ~/.config/nvim/plugins/eunuch.vim
  source ~/.config/nvim/plugins/fzf.vim
  source ~/.config/nvim/plugins/nerdtree.vim
  source ~/.config/nvim/plugins/pasta.vim
  source ~/.config/nvim/plugins/smooth-scroll.vim
  source ~/.config/nvim/plugins/splitjoin.vim
  source ~/.config/nvim/plugins/surround.vim
  source ~/.config/nvim/plugins/textobj-user.vim
  source ~/.config/nvim/plugins/theme.vim
  source ~/.config/nvim/plugins/treesitter.vim
  source ~/.config/nvim/plugins/vim-lastplace.vim
call plug#end()
doautocmd User PlugLoaded


