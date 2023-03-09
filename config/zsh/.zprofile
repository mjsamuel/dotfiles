eval "$(/opt/homebrew/bin/brew shellenv)"

export XDG_CACHE_HOME="$HOME/.cache/"
export XDG_CONFIG_HOME="$HOME/.config/"
export XDG_DATA_HOME="$HOME/.local/share"

export EDITOR=nvim
export TERM=xterm-256color

export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export LESSHISTFILE="$XDG_DATA_HOME/less_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export PLAYDATE_SDK_PATH="$XDG_DATA_HOME/PlaydateSDK"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

playdate_sdk="/usr/local/playdate/gcc-arm-none-eabi-9-2019-q4-major/bin:${PLAYDATE_SDK_PATH}/bin:$PATH"
maven="/opt/apache-maven/bin"
PATH="$PATH:${playdate_sdk}:${maven}"
