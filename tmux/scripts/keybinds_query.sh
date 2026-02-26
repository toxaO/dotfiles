#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/tmux/keybinds_notes.tsv"
query="${1:-}"
blue="$(printf '\033[34m')"
reset="$(printf '\033[0m')"

awk -F '\t' -v q="$query" '
  function tolow(s) { return tolower(s) }
  function label_rank(label) {
    if (label == "prefix") return 0
    if (label == "root") return 1
    return 2
  }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  {
    label = $1
    key = $2
    cat = $3
    desc = $4
    cmd = $5

    llabel = tolow(label)
    lkey = tolow(key)
    lcat = tolow(cat)
    ldesc = tolow(desc)
    lcmd = tolow(cmd)
    lall = tolow($0)
    lq = tolow(q)

    score = 9999
    if (lq == "") {
      score = 100
    } else if (llabel == "prefix" && lkey == lq) {
      score = 0
    } else if (llabel == "prefix" && index(lkey, lq) == 1) {
      score = 1
    } else if (llabel == "prefix" && index(lkey, lq) > 0) {
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
    } else if (index(lcmd, lq) > 0) {
      score = 30
    } else if (index(lall, lq) > 0) {
      score = 40
    } else {
      next
    }

    printf "%04d\t%d\t%s\t%s\t%s\t%s\n", score, label_rank(llabel), label, key, cat, desc
  }
' "$notes_file" | sort -t '	' -k1,1n -k2,2n -k3,3 -k5,5 -k4,4 | awk -F '\t' -v blue="$blue" -v reset="$reset" '
  {
    label = $3
    key = $4
    cat = $5
    desc = $6
    printf "%-7s %-8s %s%-10s%s %s\n", label, cat, blue, key, reset, desc
  }
'
