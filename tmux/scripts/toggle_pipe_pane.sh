#!/bin/sh
set -eu

current_pipe="$(tmux display-message -p '#{pane_pipe}' 2>/dev/null || printf '')"

if [ -n "$current_pipe" ]; then
  tmux pipe-pane
  tmux display-message "Pane logging off"
  exit 0
fi

log_dir="${HOME}/tmux-logs"
mkdir -p "$log_dir"
log_file="${log_dir}/pane-$(tmux display-message -p '#S-#I-#P')-$(date +%Y%m%d-%H%M%S).log"

tmux pipe-pane -o "cat >> '$log_file'"
tmux display-message "Pane logging on: $log_file"
