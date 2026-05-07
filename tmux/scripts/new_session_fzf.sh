#!/bin/sh
set -eu

script="$HOME/dotfiles/tmux/scripts/new_session_fzf.sh"

list_roots() {
  if [ -n "${TMUX_SESSION_DIR_ROOTS:-}" ]; then
    old_ifs="$IFS"
    IFS=:
    # shellcheck disable=SC2086
    set -- $TMUX_SESSION_DIR_ROOTS
    IFS="$old_ifs"
    for root do
      [ -d "$root" ] && printf '%s\n' "$root"
    done
    return
  fi

  [ -d "$HOME" ] && printf '%s\n' "$HOME"
  [ -d /mnt/c/Users ] && printf '%s\n' /mnt/c/Users
  [ -d /mnt/d ] && printf '%s\n' /mnt/d
}

list_dirs() {
  depth="$1"
  set -- $(list_roots)

  if command -v fd >/dev/null; then
    if [ "$depth" = "deep" ]; then
      fd -t d -H --exclude .git --exclude node_modules --exclude .cache . "$@" || true
    else
      fd -t d -H --exclude .git --exclude node_modules --exclude .cache --max-depth 3 . "$@" || true
    fi
  else
    if [ "$depth" = "deep" ]; then
      find "$@" \( -name .git -o -name node_modules -o -name .cache \) -prune -o -type d -print 2>/dev/null || true
    else
      find "$@" -maxdepth 3 \( -name .git -o -name node_modules -o -name .cache \) -prune -o -type d -print 2>/dev/null || true
    fi
  fi
}

if [ "${1:-}" = "--list-dirs" ]; then
  list_dirs "${2:-shallow}"
  exit 0
fi

base="$HOME"

if command -v fzf >/dev/null; then
  dir="$(list_dirs shallow | \
    fzf --prompt="Dir> " --height=40% \
    --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
    --bind="ctrl-d:reload(sh \"$script\" --list-dirs deep)" \
    --bind="ctrl-s:reload(sh \"$script\" --list-dirs shallow)")"
else
  dir="$base"
fi

[ -z "${dir:-}" ] && exit 0

name="$(basename "$dir")"
name="$(printf '%s' "$name" | tr ' ' '_')"
name="$(printf '%s' "$name" | cut -c 1-10)_$(date +%m%d)"
if tmux has-session -t "=${name}" 2>/dev/null; then
  tmux switch-client -t "=${name}"
else
  tmux new-session -d -s "$name" -c "$dir"
  tmux switch-client -t "=${name}"
fi
