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

awk -v tmp="$tmp_file" -v home="$HOME" -v shell="$SHELL" '
  BEGIN {
    FS = "\t"; OFS = "\t"
  }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  { notes[$1 "\t" $2] = $0 }
  END {
    cmd = "tmux list-keys -T prefix"
    while ((cmd | getline line) > 0) {
      if (line ~ /^bind-key/) {
        n = split(line, parts, /[[:space:]]+/)
        table = "prefix"
        key = ""
        cmdname = ""
        for (i = 2; i <= n; i++) {
          if (parts[i] == "-T") {
            table = parts[i+1]
            key = parts[i+2]
            cmdname = parts[i+3]
            break
          }
        }
        if (key == "") {
          # skip flags like -r/-n
          for (i = 2; i <= n; i++) {
            if (parts[i] ~ /^-/) continue
            key = parts[i]
            cmdname = parts[i+1]
            break
          }
        }
        cmdline = line
        if (home != "") gsub(home, "$HOME", cmdline)
        if (shell != "") gsub(shell, "$SHELL", cmdline)
        k = table "\t" key
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
        if (k in notes) {
          split(notes[k], f, "\t")
          if (f[3] == "") f[3] = cat
          if (f[4] == "") f[4] = ""
          rows[k] = f[1] OFS f[2] OFS f[3] OFS f[4] OFS cmdline
        } else {
          desc = ""
          rows[k] = table OFS key OFS cat OFS desc OFS cmdline
        }
        tables[k] = table
        keys[k] = key
      }
    }
    close(cmd)

    cmd = "tmux list-keys -T root"
    while ((cmd | getline line) > 0) {
      if (line ~ /^bind-key/) {
        n = split(line, parts, /[[:space:]]+/)
        table = "root"
        key = ""
        cmdname = ""
        for (i = 2; i <= n; i++) {
          if (parts[i] == "-T") {
            table = parts[i+1]
            key = parts[i+2]
            cmdname = parts[i+3]
            break
          }
        }
        if (key == "") {
          for (i = 2; i <= n; i++) {
            if (parts[i] ~ /^-/) continue
            key = parts[i]
            cmdname = parts[i+1]
            break
          }
        }
        cmdline = line
        if (home != "") gsub(home, "$HOME", cmdline)
        if (shell != "") gsub(shell, "$SHELL", cmdline)
        k = table "\t" key
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
        if (k in notes) {
          split(notes[k], f, "\t")
          if (f[3] == "") f[3] = cat
          if (f[4] == "") f[4] = ""
          rows[k] = f[1] OFS f[2] OFS f[3] OFS f[4] OFS cmdline
        } else {
          desc = ""
          rows[k] = table OFS key OFS cat OFS desc OFS cmdline
        }
        tables[k] = table
        keys[k] = key
      }
    }
    close(cmd)

    rows_file = tmp ".rows"
    for (k in rows) {
      print rows[k] >> rows_file
    }
  }
' "$notes_file"

if [ ! -s "$tmp_file.rows" ]; then
  echo "no tmux keybindings found" >&2
  rm -f "$tmp_file" "$tmp_file.rows"
  exit 1
fi

{
  printf '%s\n' '# table	key	category	description	command'
  sort -t '	' -k1,1 -k2,2 "$tmp_file.rows"
} > "$tmp_file"
rm -f "$tmp_file.rows"
mv "$tmp_file" "$notes_file"
