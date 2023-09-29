# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

OS="$(uname -s)"
if [ "$OS" = "Darwin" ]; then # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ZSH_PLUGINS="${HOMEBREW_PREFIX}/share"
    FZF_KEYBINDINGS="${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
else
    ZSH_PLUGINS="$XDG_DATA_HOME/zsh/plugins"
    FZF_KEYBINDINGS="/usr/share/doc/fzf/examples/key-bindings.zsh"
fi


HISTSIZE=10000
SAVEHIST=10000
HISTFILE="$XDG_CACHE_HOME/zsh/history"

# vi mode
bindkey -v
KEYTIMEOUT=1

# Edit line in nvim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Change cursor shape for different vi modes.
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;      # block
        viins|main) echo -ne '\e[5 q';; # beam
    esac
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# keybindings
bindkey -s '^[S' "tmux-sessionizer\n"

# fzf
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --layout=reverse --height=50% --color 16"
source "$FZF_KEYBINDINGS"

# Plugins/misc
source "${ZSH_PLUGINS}/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZSH_PLUGINS}/powerlevel10k/powerlevel10k.zsh-theme"

source "$XDG_CONFIG_HOME/zsh/powerlevel10k.zsh"
source "$XDG_CONFIG_HOME/zsh/aliases.zsh"
source "$XDG_CONFIG_HOME/zsh/functions.zsh"

eval "$(fnm env)"

export BAT_THEME="ansi"

autoload -Uz compinit
compinit
