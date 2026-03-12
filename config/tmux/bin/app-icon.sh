#!/bin/sh
# Script to return an app icon based on the tmux window name or current pane command.
# Usage: ./app-icon.sh <tmux_window_name> <pane_current_command> <is_window_selected>
window_name="$1"
pane_current_command="$2"
is_selected="$3"

return_app() {
	app_icon="$1"
	color="$2"
	if [ "$is_selected" -eq 0 ]; then
		color="gray"
	fi
	printf "#[fg=%s]%s#[default]" "$color" "$app_icon"
	exit 0
}

case "$window_name" in
logs) return_app '' 'white' ;;
ai | claude*) return_app '󰫢' 'orange' ;;
*capture) return_app '󰆟' 'blue' ;;
esac

case "$pane_current_command" in
*git*) return_app "" "red" ;;
air) return_app "" "blue" ;;
bat) return_app "󰄛" "blue" ;;
docker) return_app "" "blue" ;;
go) return_app "" "blue" ;;
java) return_app "" "red" ;;
jira) return_app "󰌃" "blue" ;;
man) return_app "󰈙" "blue" ;;
newsboat) return_app "" "orange" ;;
node | npm) return_app "󰆧" "green" ;;
nvim) return_app "" "green" ;;
python) return_app "" "yellow" ;;
ruby) return_app "" "red" ;;
ssh) return_app "󰌘" "white" ;;
tt) return_app "󰌌" "white" ;;
vim) return_app "" "green" ;;
yt-dl*) return_app "󰇚" "green" ;;
*) return_app "" "orange" ;;
esac
