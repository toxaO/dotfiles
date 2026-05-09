#!/bin/sh
set -eu

cat <<'EOF'
tmux quick help

Start / attach
  tm                 open the startup selector
  tls                list sessions
  ta NAME            attach to a session
  tn NAME            attach or create a session

Inside tmux
  Prefix s           popup shell in current directory
  Prefix S           choose session/window/pane tree
  Prefix S, then N   create a session from a directory picker
  Prefix A           attach or create a session by name
  Prefix C           create a session from a directory picker
  Prefix N / P       next / previous session
  Prefix d           detach current client
  Prefix $           rename current session

Windows / panes
  Prefix t           new window
  Prefix c / y       copy mode
  Prefix ,           rename window
  Prefix n / p       next / previous window
  Prefix [ / ]       move current window left / right, keep it active
  Prefix w s / v     split vertically / horizontally
  Prefix h/j/k/l     focus pane
  Prefix arrows      move pane
  Prefix H/J/K/L     resize pane by 5
  Prefix M-h/j/k/l   resize pane by 1
  Shift arrows       focus pane without prefix
  Prefix g           choose pane by number
  Prefix x           kill pane
  Prefix r           respawn current pane
  Prefix R           toggle pane recording
  Prefix C-z         zoom pane
  Prefix Y           capture last 3000 lines
  Prefix v / V       paste buffer / list buffers

Help
  Prefix /           searchable tmux keybinds
  Prefix ?           searchable zsh commands
EOF
