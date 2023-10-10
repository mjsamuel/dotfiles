# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Plugins
ZSH_PLUGIN_DIR="/usr/local/zsh/plugins"
source "${ZSH_PLUGIN_DIR}/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZSH_PLUGIN_DIR}/powerlevel10k/powerlevel10k.zsh-theme"

# Load aliases and functions
source "$XDG_CONFIG_HOME/zsh/powerlevel10k.zsh"
for file in "$XDG_CONFIG_HOME/shell/"*; do
    source "$file"
done

# Variables
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"
export KEYTIMEOUT=1 # waittime for key to be presseded before executing
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --layout=reverse --height=50% --color 16"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --null 2> /dev/null | xargs -0 dirname | sort | uniq"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND 2> /dev/null"
export BAT_THEME="ansi"
export OS_APPEARANCE_FILE="$XDG_CACHE_HOME/os_theme"

# Load environment variables for brew and fnm
command -v brew >/dev/null && eval "$(brew shellenv)" 
command -v fnm >/dev/null && eval "$(fnm env)"

# Misc
setopt autocd # Automatically cd into typed directory.
autoload -Uz compinit
compinit

# keybindings
bindkey -v # vi mode
bindkey "^?" backward-delete-char # delete with backspace
bindkey '^e' edit-command-line; autoload edit-command-line; zle -N edit-command-line # Edit line in nvim
bindkey -s '^[S' "tmux-sessionizer\n"
source "/usr/local/fzf/key-bindings.zsh"

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.
