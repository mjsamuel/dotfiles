Plug 'ayu-theme/ayu-vim'

let ayucolor="dark"
autocmd User PlugLoaded ++nested colorscheme ayu

map <C-s> :call ToggleColor()<CR>
function ToggleColor()
  if g:ayucolor==?"dark"
    let g:ayucolor="mirage"
    let g:airline_theme = 'ayu_mirage'
  else
    let g:ayucolor="dark"
    let g:airline_theme = 'ayu_dark'
  endif
  colorscheme ayu
endfunction
