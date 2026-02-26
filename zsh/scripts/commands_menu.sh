#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/zsh/commands_notes.tsv"
blue="$(printf '\033[34m')"
reset="$(printf '\033[0m')"

if [ ! -f "$notes_file" ]; then
  exit 0
fi

awk '
  BEGIN { FS = "\t" }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  { print $0 }
' "$notes_file" | sort -t '	' -k1,1 -k2,2 | awk -v blue="$blue" -v reset="$reset" '
  BEGIN { FS = "\t" }
  {
    typ = $1
    name = $2
    cat = $3
    desc = $4
    printf "%-8s %-10s %s%-16s%s %s\n", typ, cat, blue, name, reset, desc
  }
' | {
  if command -v fzf >/dev/null; then
    fzf --ansi --no-sort --prompt="Zsh commands> " \
      --header="Type to search. Enter/ESC to close." \
      --bind="enter:abort,esc:abort"
  else
    LESS="-RSX" less
  fi
}
