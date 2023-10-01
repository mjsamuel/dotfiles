# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

if [[ "$OSTYPE" =~ "darwin" ]]; then # macOS
    eval "$(/opt/homebrew/bin/brew shellenv)"
    ZSH_PLUGINS="${HOMEBREW_PREFIX}/share"
    FZF_KEYBINDINGS="${HOMEBREW_PREFIX}/opt/fzf/shell/key-bindings.zsh"
else
    ZSH_PLUGINS="$XDG_DATA_HOME/zsh/plugins"
    FZF_KEYBINDINGS="/usr/share/doc/fzf/examples/key-bindings.zsh"
fi

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

# keybindings
bindkey -v # vi mode
bindkey "^?" backward-delete-char # delete with backspace
bindkey '^e' edit-command-line; autoload edit-command-line; zle -N edit-command-line # Edit line in nvim
bindkey -s '^[S' "tmux-sessionizer\n"
source "$FZF_KEYBINDINGS"

# Plugins/misc
source "${ZSH_PLUGINS}/zsh-autosuggestions/zsh-autosuggestions.zsh"
source "${ZSH_PLUGINS}/powerlevel10k/powerlevel10k.zsh-theme"
source "$XDG_CONFIG_HOME/zsh/powerlevel10k.zsh"
source "$XDG_CONFIG_HOME/zsh/aliases.zsh"
source "$XDG_CONFIG_HOME/zsh/functions.zsh"

export KEYTIMEOUT=1 # waittime for key to be presseded before executing
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --layout=reverse --height=50% --color 16"
export FZF_ALT_C_COMMAND="$FZF_DEFAULT_COMMAND --null 2> /dev/null | xargs -0 dirname | sort | uniq"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND 2> /dev/null"
export BAT_THEME="ansi"
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/history"

setopt autocd # Automatically cd into typed directory.

eval "$(fnm env)"

autoload -Uz compinit
compinit
