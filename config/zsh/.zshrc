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

# Variables/Options
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
setopt INC_APPEND_HISTORY     # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY          # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS       # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS   # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS      # Do not display a line previously found.
setopt HIST_IGNORE_SPACE      # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS      # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks before recording entry.
unsetopt autocd beep notify

# Load environment variables for brew and fnm
command -v brew >/dev/null && eval "$(brew shellenv)" 
command -v fnm >/dev/null && eval "$(fnm env)"
command -v fzf >/dev/null && eval "$(fzf --zsh)"
command -v go >/dev/null && eval "$(go env)"
command -v opam >/dev/null && eval "$(opam env)"

# keybindings
bindkey -v # vi mode
bindkey "^?" backward-delete-char # delete with backspace
bindkey '^e' edit-command-line; autoload edit-command-line; zle -N edit-command-line # Edit line in nvim
bindkey -s '^[S' "tmux-sessionizer\n"
bindkey -s '^[N' "notarizer\n"

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

autoload -Uz compinit
compinit
