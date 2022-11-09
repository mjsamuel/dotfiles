# misc
alias c='clear'
alias ls='exa'
alias cat='bat'
alias rtv='python3 -m rtv'
alias tt='tt -theme ayu -showwpm'
alias v='nvim'
alias b='brew'

# ssh
alias s='ssh'
alias sshhosts="grep -w -i -E 'Host|HostName' ~/.ssh/config | sed 's/Host //' | sed 's/HostName //'"

# youtube-dl
alias yt='yt-dlp --no-abort-on-error --embed-metadata -i'
alias yta="yt-dlp -x -f bestaudio/best"

# tmux
alias t="tmux"
alias ta="tmux attach"
