set expandtab
set shiftwidth=4
set tabstop=4
set hidden
set signcolumn=yes:2
set relativenumber
set number
set termguicolors
set undofile
set spell
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

let mapleader = "\<space>"
nmap <leader>ve :edit ~/.config/nvim/init.vim<cr>
nmap <leader>vc :edit ~/.config/nvim/coc-settings.json<cr>
nmap <leader>vr :source ~/.config/nvim/init.vim<cr>

" Allow gf to open non-existent files
map gf :edit <cfile><cr>
" Easy insertion of a trailing ; or , from insert mode
imap ;; <Esc>A;<Esc>
imap ,, <Esc>A,<Esc>

let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin(data_dir . '/plugins')
  source ~/.config/nvim/plugins/ayu.vim
  source ~/.config/nvim/plugins/airline.vim
  source ~/.config/nvim/plugins/surround.vim
  source ~/.config/nvim/plugins/nerdtree.vim
  source ~/.config/nvim/plugins/markdown-preview.vim
  source ~/.config/nvim/plugins/heritage.vim
  source ~/.config/nvim/plugins/coc.vim
  source ~/.config/nvim/plugins/commentary.vim
  source ~/.config/nvim/plugins/vim-lastplace.vim
  source ~/.config/nvim/plugins/pasta.vim
  source ~/.config/nvim/plugins/floaterm.vim
  source ~/.config/nvim/plugins/editorconfig.vim
  source ~/.config/nvim/plugins/quickscope.vim
  source ~/.config/nvim/plugins/smooth-scroll.vim
  source ~/.config/nvim/plugins/splitjoin.vim
  source ~/.config/nvim/plugins/fzf.vim
  source ~/.config/nvim/plugins/eunuch.vim
  source ~/.config/nvim/plugins/replacewithregister.vim
  source ~/.config/nvim/plugins/textobj-user.vim
call plug#end()
doautocmd User PlugLoaded

