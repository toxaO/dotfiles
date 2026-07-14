#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
user_dir="$HOME/Library/Application Support/Code/User"
settings_file="$repo_dir/vscode/common/settings.json"
extensions_file="$repo_dir/vscode/mac/extensions.txt"
code_cmd="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"

link_file() {
  src=$1
  dest=$2

  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    ln -sfn "$src" "$dest"
  else
    backup="$dest.bak.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "backup: $dest -> $backup" >&2
    ln -sfn "$src" "$dest"
  fi
}

install_extensions() {
  if [ ! -x "$code_cmd" ]; then
    if command -v code >/dev/null 2>&1; then
      code_cmd=$(command -v code)
    fi
  fi

  if [ ! -x "$code_cmd" ]; then
    echo "skip extension install: code command not found" >&2
    return 0
  fi

  while IFS= read -r ext; do
    case "$ext" in
      ''|'#'*) continue ;;
    esac
    if ! "$code_cmd" --install-extension "$ext" --force >/dev/null; then
      echo "skip extension install: $ext not available" >&2
    fi
  done < "$extensions_file"
}

mkdir -p "$user_dir"
link_file "$settings_file" "$user_dir/settings.json"

install_extensions
