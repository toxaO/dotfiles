#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/tmux/keybinds_notes.tsv"
query_script="${HOME}/dotfiles/tmux/scripts/keybinds_query.sh"

if [ ! -f "$notes_file" ]; then
  tmux list-keys -T prefix
  tmux list-keys -T root
  exit 0
fi

if command -v fzf >/dev/null; then
  fzf --ansi --disabled --prompt="All keybinds> " \
    --header="Priority: key match > description match. Enter/ESC to close." \
    --bind="start:reload:sh $query_script ''" \
    --bind="change:reload:sh $query_script {q}" \
    --bind="enter:abort,esc:abort"
else
  sh "$query_script" "" | LESS="-RSX" less
fi
