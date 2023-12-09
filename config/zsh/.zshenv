export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"

export EDITOR=nvim
export TERM=xterm-256color

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"

export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

export ANSIBLE_HOME="$XDG_DATA_HOME/ansible"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export LESSHISTFILE="$XDG_DATA_HOME/less_history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PLAYDATE_SDK_PATH="$XDG_DATA_HOME/playdate"
export PYENV_ROOT="$XDG_DATA_HOME/pyenv"
export PYTHONSTARTUP="$XDG_CONFIG_HOME/python/pythonrc"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export SQLITE_HISTORY="$XDG_DATA_HOME/sqlite_history"
export YARN_CACHE_FOLDER="$XDG_CACHE_HOME/yarn/v6"

# Path
export PATH="$HOME/Developer/dotfiles/scripts\
:/opt/apache-maven/bin\
:$PLAYDATE_SDK_PATH/bin\
:$CARGO_HOME/bin\
:$PATH
"
