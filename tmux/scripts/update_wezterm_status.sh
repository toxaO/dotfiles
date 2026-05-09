#!/bin/sh
set -eu

session="$(tmux display-message -p '#S' 2>/dev/null || printf '')"
path="$(tmux display-message -p '#{pane_current_path}' 2>/dev/null || printf '')"
host="$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf '')"
pane_tty="$(tmux display-message -p '#{pane_tty}' 2>/dev/null || printf '')"

case "$path" in
  "$HOME") short_path="~" ;;
  "$HOME"/*) short_path="~${path#"$HOME"}" ;;
  *) short_path="$path" ;;
esac

neighbor_sessions() {
  direction="$1"
  sessions="$(tmux list-sessions -F '#{session_name}' 2>/dev/null || printf '')"
  [ -n "$sessions" ] || return 0

  awk -v current="$session" -v direction="$direction" '
    { names[++count] = $0 }
    END {
      if (count < 2) exit
      for (i = 1; i <= count; i++) {
        if (names[i] == current) {
          if (direction == "prev") {
            print names[i == 1 ? count : i - 1]
          } else {
            print names[i == count ? 1 : i + 1]
          }
          exit
        }
      }
    }
  ' <<EOF
$sessions
EOF
}

set_user_var() {
  name="$1"
  value="$2"
  encoded="$(printf '%s' "$value" | base64 | tr -d '\r\n')"
  printf '\033Ptmux;\033\033]1337;SetUserVar=%s=%s\007\033\\' "$name" "$encoded" > "$pane_tty"
}

[ -n "$pane_tty" ] || exit 0
[ -w "$pane_tty" ] || exit 0

set_user_var WEZTERM_IN_TMUX 1
set_user_var WEZTERM_TMUX_SESSION "$session"
set_user_var WEZTERM_TMUX_SESSION_PREV "$(neighbor_sessions prev)"
set_user_var WEZTERM_TMUX_SESSION_NEXT "$(neighbor_sessions next)"
set_user_var WEZTERM_CWD_SHORT "$short_path"
set_user_var WEZTERM_HOST "$host"
