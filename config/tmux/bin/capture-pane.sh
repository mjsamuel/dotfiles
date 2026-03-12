#!/bin/sh
# Save the current tmux pane buffer to a timestamped file in /tmp.
# Usage: capture-pane.sh [--open-in-nvim]

pane_info=$(tmux display-message -p "#{pane_current_command}_w#{window_index}_p#{pane_index}")
timestamp=$(date +%Y%m%d_%H%M%S)
file="/tmp/tmux_buffer_${timestamp}_${pane_info}"

tmux save-buffer "$file"

if [ "$1" = "--open-in-nvim" ]; then
    tmux new-window -n "capture" "cat $file | nvim"
fi
