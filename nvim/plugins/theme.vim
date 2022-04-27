Plug 'tobi-wan-kenobi/zengarden'
Plug 'ayu-theme/ayu-vim'

autocmd User PlugLoaded ++nested call DarkModeDetection()
autocmd CursorHold,CursorHoldI call DarkModeDetection()
function DarkModeDetection()
    if has('macunix')
        let output = system('defaults read -g AppleInterfaceStyle')
    elseif has('win32unix')
        let output = system('powershell.exe "Get-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme" | grep 0')
    endif
    if v:shell_error == 0
        call ChangeColorschemeDark()
    else
        call ChangeColorschemeLight()
    endif
endfunction

map <leader>s :call ToggleColor()<CR>
function ToggleColor()
    if g:colors_name==?"ayu"
        call ChangeColorschemeLight()
    else
        call ChangeColorschemeDark()
    endif
endfunction

function ChangeColorschemeDark()
    colorscheme ayu
    let $BAT_THEME=''
endfunction

function ChangeColorschemeLight()
    set background=light
    colorscheme zengarden
    let $BAT_THEME='Monokai Extended Light'
endfunction
