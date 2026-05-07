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
  Prefix s           choose session/window/pane tree
  Prefix s, then N   create a session from a directory picker
  Prefix A           attach or create a session by name
  Prefix C           create a session from a directory picker
  Prefix N / P       next / previous session
  Prefix d           detach current client
  Prefix $           rename current session

Windows / panes
  Prefix c           new window
  Prefix ,           rename window
  Prefix n / p       next / previous window
  Prefix w s / v     split vertically / horizontally
  Prefix h/j/k/l     focus pane
  Shift arrows       focus pane without prefix
  Prefix g           choose pane by number
  Prefix x           kill pane
  Prefix C-z         zoom pane

Help
  Prefix /           searchable tmux keybinds
  Prefix ?           searchable zsh commands
  Prefix H           this quick help
EOF
