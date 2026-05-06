#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/wezterm/keybinds.tsv"
query="${1:-}"
blue="$(printf '\033[34m')"
reset="$(printf '\033[0m')"

awk -F '\t' -v q="$query" '
  function tolow(s) { return tolower(s) }
  function group_rank(shortcut) {
    if (shortcut ~ /^leader \+/) return 0
    return 2
  }
  function key_part(shortcut, out) {
    out = shortcut
    sub(/^[^+]+\+ /, "", out)
    return tolow(out)
  }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  {
    shortcut = $1
    cat = $2
    desc = $3
    action = $4

    lshortcut = tolow(shortcut)
    lcat = tolow(cat)
    ldesc = tolow(desc)
    laction = tolow(action)
    lq = tolow(q)
    lkey = key_part(shortcut)

    score = 9999
    if (lq == "") {
      score = 100
    } else if (shortcut ~ /^leader \+/ && lkey == lq) {
      score = 0
    } else if (shortcut ~ /^leader \+/ && index(lkey, lq) == 1) {
      score = 1
    } else if (shortcut ~ /^leader \+/ && index(lkey, lq) > 0) {
      score = 2
    } else if (lkey == lq) {
      score = 3
    } else if (index(lkey, lq) == 1) {
      score = 4
    } else if (index(lkey, lq) > 0) {
      score = 5
    } else if (index(ldesc, lq) > 0) {
      score = 10
    } else if (index(lcat, lq) > 0) {
      score = 20
    } else if (index(laction, lq) > 0) {
      score = 30
    } else if (index(lshortcut, lq) > 0) {
      score = 40
    } else {
      next
    }

    printf "%04d\t%d\t%s\t%s\t%s\n", score, group_rank(shortcut), shortcut, cat, desc
  }
' "$notes_file" | sort -t '\t' -k1,1n -k2,2n -k3,3 | awk -F '\t' -v blue="$blue" -v reset="$reset" '
  {
    shortcut = $3
    cat = $4
    desc = $5
    printf "%s%-22s%s %-10s %s\n", blue, shortcut, reset, cat, desc
  }
'
