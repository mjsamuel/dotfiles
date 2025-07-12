#!/bin/sh
# Usage: ./app-icon.sh <tmux_window_name>

case "$1" in
*git*) echo '#[fg=red]#[default]' ;;
ai | claude*) echo '#[fg=orange]󰫢#[default]' ;;
air) echo '#[fg=blue]#[default]' ;;
bat) echo '#[fg=blue]󰄛#[default]' ;;
docker) echo '#[fg=blue]#[default]' ;;
go) echo '#[fg=blue]#[default]' ;;
java) echo '#[fg=red]#[default]' ;;
jira) echo '#[fg=blue]󰌃#[default]' ;;
logs) echo '#[fg=white]#[default]' ;;
man) echo '#[fg=blue]󰈙#[default]' ;;
newsboat) echo '#[fg=orange]#[default]' ;;
node | npm) echo '#[fg=green]󰆧#[default]' ;;
nvim) echo '#[fg=green]#[default]' ;;
python) echo '#[fg=yellow]#[default]' ;;
ruby) echo '#[fg=red]#[default]' ;;
tt) echo '#[fg=white]󰌌#[default]' ;;
vim) echo '#[fg=green]#[default]' ;;
*) echo '#[fg=orange]#[default]' ;;
esac
