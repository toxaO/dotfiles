#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/tmux/keybinds_notes.tsv"
tmp_file="${notes_file}.tmp"

afk='{
  if (cmd ~ /window/) return "window";
  if (cmd ~ /pane/) return "pane";
  if (cmd ~ /session|client/) return "session";
  if (cmd ~ /buffer|paste|copy/) return "buffer";
  if (cmd ~ /layout/) return "layout";
  if (cmd ~ /menu|prompt|message/) return "ui";
  if (cmd ~ /copy-mode/) return "copy";
  if (cmd ~ /clock/) return "ui";
  return "other";
}'

awk -v tmp="$tmp_file" '
  BEGIN {
    FS = "\t"; OFS = "\t"
  }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  { notes[$1 "\t" $2] = $0 }
  END {
    while ((cmd = "tmux list-keys -T prefix; tmux list-keys -T root") | getline line) {
      if (line ~ /^bind-key[[:space:]]+-T[[:space:]]+/) {
        n = split(line, parts, /[[:space:]]+/)
        table = parts[3]
        key = parts[4]
        cmdname = parts[5]
        cmdline = line
        k = table "\t" key
        if (k in notes) {
          # keep existing row, but refresh command column
          split(notes[k], f, "\t")
          # f[1]=table f[2]=key f[3]=category f[4]=description f[5]=command
          if (f[3] == "") f[3] = cat
          if (f[4] == "") f[4] = ""
          rows[k] = f[1] OFS f[2] OFS f[3] OFS f[4] OFS cmdline
        } else {
          # category heuristics
          cat = cmdname
          gsub(/-/, " ", cat)
          if (cmdname ~ /window/) cat = "window"
          else if (cmdname ~ /pane/) cat = "pane"
          else if (cmdname ~ /session|client/) cat = "session"
          else if (cmdname ~ /buffer|paste|copy/) cat = "buffer"
          else if (cmdname ~ /layout/) cat = "layout"
          else if (cmdname ~ /menu|prompt|message|clock/) cat = "ui"
          else if (cmdname ~ /copy-mode/) cat = "copy"
          else cat = "other"
          desc = ""
          rows[k] = table OFS key OFS cat OFS desc OFS cmdline
        }
        tables[k] = table
        keys[k] = key
      }
    }
    close(cmd)
    print "# table\tkey\tcategory\tdescription\tcommand" > tmp
    for (k in rows) {
      print rows[k] >> tmp
    }
  }
' "$notes_file"

mv "$tmp_file" "$notes_file"
