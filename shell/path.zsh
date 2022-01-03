export PATH=$PATH:/opt/apache-maven/bin

export PATH="/usr/local/opt/ruby/bin:$PATH"
export PATH="$HOME/.gem/ruby/2.7.0/bin:$PATH"
export PATH="$PATH:$HOME/.rvm/bin"

export PATH="$HOME/.pyenv/bin:$PATH"
# Commented out due to slow shell startup times
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

# Application paths
CAT="/bin/cat"
TMUX="/usr/bin/tmux"
TPUT="/usr/bin/tput"
CMD="/mnt/c/Windows/system32/cmd.exe"
GREP='/usr/bin/grep'
XARGS='/usr/bin/xargs'
CUT='/usr/bin/cut'

# MISC
BOLD="$($TPUT bold)"
COLOR_RED="$($TPUT setaf 1)"
COLOR_GREEN="$($TPUT setaf 2)"
COLOR_YELLOW="$($TPUT setaf 3)"
COLOR_RESET="$($TPUT sgr0)" 

