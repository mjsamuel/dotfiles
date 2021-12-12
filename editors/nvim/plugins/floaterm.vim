Plug 'voldikss/vim-floaterm'

let g:floaterm_keymap_toggle = '<leader>jj'
let g:floaterm_keymap_next   = '<leader>jk'
let g:floaterm_keymap_prev   = '<leader>jh'
let g:floaterm_keymap_new    = '<leader>jn'

let g:floaterm_gitcommit='floaterm'
let g:floaterm_autoinsert=1
let g:floaterm_width=0.8
let g:floaterm_height=0.8
let g:floaterm_wintitle=0
let g:floaterm_autoclose=1

augroup FloatermCustomisations
    autocmd!
    autocmd ColorScheme * highlight FloatermBorder guibg=none
augroup END
