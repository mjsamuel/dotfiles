#!/bin/sh
# Displays a tmux menu to switch to the window that triggered a Claude Code notification.
# Called from the Claude Code Notification hook (receives JSON via stdin).

input=$(cat)

title=$(printf '%s' "$input" | jq -r '.title // empty')
message=$(printf '%s' "$input" | jq -r '.message // empty')

[ -z "$TMUX_PANE" ] && exit 0

session=$(tmux display-message -t "$TMUX_PANE" -p '#{session_name}')
window=$(tmux display-message -t "$TMUX_PANE" -p '#{window_index}')

current_session=$(tmux display-message -p '#{session_name}')
current_window=$(tmux display-message -p '#{window_index}')
[ "$session" = "$current_session" ] && [ "$window" = "$current_window" ] && exit 0

header="${title:+$title: }${message:-Claude needs attention}"

tmux display-menu -T "$header" -x C -y C \
	"Switch to ${session}:${window}" y "switch-client -t ${session}:${window}" \
	"" \
	"Dismiss" n ""
