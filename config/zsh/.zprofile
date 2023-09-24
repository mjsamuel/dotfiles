eval "$(/opt/homebrew/bin/brew shellenv)"

export XDG_CACHE_HOME="$HOME/.cache/"
export XDG_CONFIG_HOME="$HOME/.config/"
export XDG_DATA_HOME="$HOME/.local/share"

export EDITOR=nvim
export TERM=xterm-256color

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export LESSHISTFILE="$XDG_DATA_HOME/less_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"

# Path
export PATH="$PATH\
:$HOME/Developer/dotfiles/scripts\
:/opt/apache-maven/bin\
:$CARGO_HOME
"

# misc
export BAT_THEME="base16-256"
