#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/tmux/keybinds_notes.tsv"
blue="$(printf '\033[34m')"
reset="$(printf '\033[0m')"

if [ ! -f "$notes_file" ]; then
  tmux list-keys -T prefix
  tmux list-keys -T root
  exit 0
fi

awk '
  BEGIN { FS = "\t" }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  { print $0 }
' "$notes_file" | sort -t '	' -k1,1 -k3,3 -k2,2 | awk -v blue="$blue" -v reset="$reset" '
  BEGIN { FS = "\t" }
  {
    label = $1
    key = $2
    cat = $3
    desc = $4
    printf "%-7s %-8s %s%-10s%s %s\n", label, cat, blue, key, reset, desc
  }
' | {
  if command -v fzf >/dev/null; then
    fzf --ansi --no-sort --prompt="All keybinds> " \
      --header="Type to search. Enter/ESC to close." \
      --bind="enter:abort,esc:abort"
  else
    LESS="-RSX" less
  fi
}
