#!/bin/sh
window_name="$1"
pane_current_command="$2"

case "$window_name" in
logs)
    echo '#[fg=white]#[default]'
    exit
    ;;
esac

case "$pane_current_command" in
*git*) echo '#[fg=red]#[default]' ;;
bat) echo '#[fg=blue]󰄛#[default]' ;;
docker) echo '#[fg=blue]#[default]' ;;
go) echo '#[fg=blue]#[default]' ;;
java) echo '#[fg=red]#[default]' ;;
jira) echo '#[fg=blue]󰌃#[default]' ;;
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
