#!/bin/sh
set -eu

out_dir="${TMPDIR:-/tmp}"
out_file="${out_dir%/}/tmux-capture-$(date +%Y%m%d-%H%M%S).log"

tmux capture-pane -p -S -3000 > "$out_file"

if command -v pbcopy >/dev/null 2>&1; then
  pbcopy < "$out_file"
  copied="copied to clipboard"
elif command -v wl-copy >/dev/null 2>&1; then
  wl-copy < "$out_file"
  copied="copied to clipboard"
elif command -v xclip >/dev/null 2>&1; then
  xclip -selection clipboard < "$out_file"
  copied="copied to clipboard"
elif command -v xsel >/dev/null 2>&1; then
  xsel --clipboard --input < "$out_file"
  copied="copied to clipboard"
elif command -v clip.exe >/dev/null 2>&1; then
  clip.exe < "$out_file"
  copied="copied to clipboard"
else
  copied="clipboard unavailable"
fi

tmux display-message "Captured last 3000 lines: $out_file ($copied)"
