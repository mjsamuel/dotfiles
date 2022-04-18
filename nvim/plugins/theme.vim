Plug 'tobi-wan-kenobi/zengarden'
Plug 'ayu-theme/ayu-vim'

autocmd User PlugLoaded ++nested call DarkModeDetection()
autocmd CursorHold,CursorHoldI call DarkModeDetection()
function DarkModeDetection()
    if has('macunix')
        let output = system('defaults read -g AppleInterfaceStyle')
        if v:shell_error == 0
            colorscheme ayu
        else
            set background=light
            colorscheme zengarden
        endif
    else
        colorscheme ayu
    endif
endfunction

map <leader>s :call ToggleColor()<CR>
function ToggleColor()
    if g:colors_name==?"ayu"
        set background=light
        colorscheme zengarden
    else
        colorscheme ayu
    endif
endfunction
