#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/wezterm/keybinds.tsv"
query_script="${HOME}/dotfiles/wezterm/scripts/keybinds_query.sh"

if [ ! -f "$notes_file" ]; then
  echo "Missing $notes_file"
  exit 1
fi

if command -v fzf >/dev/null; then
  fzf --ansi --disabled --prompt="WezTerm keybinds> " \
    --header="Priority: leader key match > key match > description match. Enter/ESC to close." \
    --bind="start:reload:sh $query_script ''" \
    --bind="change:reload:sh $query_script {q}" \
    --bind="enter:abort,esc:abort"
else
  sh "$query_script" "" | LESS="-RSX" less
fi
