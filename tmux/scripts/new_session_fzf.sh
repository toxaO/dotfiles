#!/bin/sh
set -eu

base="$HOME"

if command -v fzf >/dev/null; then
  if command -v fd >/dev/null; then
    dir="$(fd -t d -H --exclude .git --exclude node_modules --exclude .cache --max-depth 3 . "$base" | \
      fzf --prompt="Dir> " --height=40% \
      --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
      --bind="ctrl-d:reload(fd -t d -H --exclude .git --exclude node_modules --exclude .cache . \"$base\")" \
      --bind="ctrl-s:reload(fd -t d -H --exclude .git --exclude node_modules --exclude .cache --max-depth 3 . \"$base\")")"
  else
    dir="$(find "$base" -maxdepth 3 -type d 2>/dev/null | \
      fzf --prompt="Dir> " --height=40% \
      --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
      --bind="ctrl-d:reload(find \"$base\" -type d 2>/dev/null)" \
      --bind="ctrl-s:reload(find \"$base\" -maxdepth 3 -type d 2>/dev/null)")"
  fi
else
  dir="$base"
fi

[ -z "${dir:-}" ] && exit 0

name="$(basename "$dir")"
name="${name// /_}_$(date +%Y%m%d)"
tmux new-session -s "$name" -c "$dir"
