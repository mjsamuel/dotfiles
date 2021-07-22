" Installing plugins
call plug#begin('~/.vim/plugged')

Plug 'junegunn/goyo.vim'
Plug 'junegunn/limelight.vim'
Plug 'arcticicestudio/nord-vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'itchyny/lightline.vim'
Plug 'airblade/vim-gitgutter'
Plug 'ayu-theme/ayu-vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'tpope/vim-surround'

call plug#end()

" ColorScheme
set termguicolors
let ayucolor="dark"
colorscheme ayu
if (has("termguicolors"))
  set termguicolors
endif
" toggle between dark and light mode
map <C-s> :call ToggleColor()<CR>
function ToggleColor()
  if g:ayucolor==?"dark"
    let g:ayucolor="light"
  else
    let g:ayucolor="dark"
  endif
  colorscheme ayu
endfunction 

" NerdTree Settings
autocmd StdinReadPre * let s:std_in=1
" open NerdTree automatically if no file is specified
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" Lightline
" display the status line
set laststatus=2
" setting ayu colors
let g:lightline = { 'colorscheme': 'ayu' }
let g:airline_theme = 'ayu'
" hide things like -- INSERT -- as lightline replaces this
set noshowmode

" Invisibles
" showing invisibles
set list
" changing how invisible characters are shown
set listchars=tab:→\ ,space:·,nbsp:␣,trail:•,eol:¬,precedes:«,extends:»
" Rebindings
map <C-f> :Files<CR>
map <C-o> :NERDTreeToggle<CR>

" Indentation
" setting the default number of spaces
set tabstop=4
set shiftwidth=4
" setting indentation for specifc file types (default is 4)
autocmd BufRead,BufNewFile *.html,*.js,*.jsx,*.sh,*.yml setlocal ts=2 sts=2 sw=2 
" insert spaces when tab is pressed
set expandtab

" Misc
" show linenumbers
set number
" display a ruler
set colorcolumn=80
" Reloads vimrc on save
autocmd bufwritepost .vimrc source ~/.vimrc

" Sortcut to run python file when F9 is pressed 
autocmd FileType python map <F8> :w<CR>:exec '!clear; python %'<CR>
