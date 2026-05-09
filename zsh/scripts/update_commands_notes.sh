#!/bin/sh
set -eu

notes_file="${HOME}/dotfiles/zsh/commands_notes.tsv"
tmp_file="${notes_file}.tmp"
alias_file="${HOME}/dotfiles/zsh/alias.zsh"
func_file="${HOME}/dotfiles/zsh/func.zsh"

awk -v alias_file="$alias_file" -v func_file="$func_file" '
  BEGIN { FS = "\t"; OFS = "\t" }
  NR == 1 && $1 ~ /^#/ { next }
  $1 == "" || $2 == "" { next }
  { notes[$1 "\t" $2] = $0 }
  END {
    # aliases
    while ((getline line < alias_file) > 0) {
      if (line ~ /^[[:space:]]*alias[[:space:]]+[a-zA-Z0-9_\\.:-]+=/) {
        sub(/^[[:space:]]*alias[[:space:]]+/, "", line)
        split(line, parts, "=")
        name = parts[1]
        cmd = substr(line, index(line, "=") + 1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", cmd)
        gsub(/^'\''|'\''$/, "", cmd)
        gsub(/^\"|\"$/, "", cmd)
        sub(/[[:space:]]+#.*/, "", cmd)
        key = "alias" OFS name
        if (key in notes) {
          split(notes[key], f, "\t")
          rows[key] = f[1] OFS f[2] OFS f[3] OFS f[4] OFS "alias: " cmd
        } else {
          rows[key] = "alias" OFS name OFS "" OFS "" OFS "alias: " cmd
        }
      }
    }
    close(alias_file)

    # functions
    while ((getline line < func_file) > 0) {
      name = ""
      if (line ~ /^[[:space:]]*function[[:space:]]+/) {
        sub(/^[[:space:]]*function[[:space:]]+/, "", line)
        sub(/[[:space:]]*\(.*/, "", line)
        sub(/[[:space:]]*\{.*/, "", line)
        name = line
      } else if (index(line, "()") > 0 && index(line, "{") > 0) {
        if (match(line, /^[[:space:]]*[a-zA-Z0-9_]+/)) {
          name = substr(line, RSTART, RLENGTH)
        }
      }

      if (name != "" && name !~ /^_/) {
        key = "function" OFS name
        if (key in notes) {
          split(notes[key], f, "\t")
          rows[key] = f[1] OFS f[2] OFS f[3] OFS f[4] OFS "function: zsh/func.zsh"
        } else {
          rows[key] = "function" OFS name OFS "" OFS "" OFS "function: zsh/func.zsh"
        }
      }
    }
    close(func_file)

    rows_file = "'"$tmp_file"'.rows"
    for (k in rows) {
      print rows[k] >> rows_file
    }
  }
' "$notes_file"

if [ ! -s "$tmp_file.rows" ]; then
  echo "no zsh commands found" >&2
  rm -f "$tmp_file" "$tmp_file.rows"
  exit 1
fi

{
  printf '%s\n' '# type	name	category	description	source'
  sort -t '	' -k1,1 -k2,2 "$tmp_file.rows"
} > "$tmp_file"
rm -f "$tmp_file.rows"
mv "$tmp_file" "$notes_file"
