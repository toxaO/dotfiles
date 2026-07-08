#!/bin/sh

set -eu

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/../.." && pwd)
user_dir="$HOME/Library/Application Support/Code/User"
settings_file="$repo_dir/vscode/common/settings.json"
extensions_file="$repo_dir/vscode/mac/extensions.txt"

link_file() {
  src=$1
  dest=$2

  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    ln -sfn "$src" "$dest"
  else
    echo "skip link: $dest already exists and is not a symlink" >&2
  fi
}

install_extensions() {
  if ! command -v code >/dev/null 2>&1; then
    echo "skip extension install: code command not found" >&2
    return 0
  fi

  while IFS= read -r ext; do
    case "$ext" in
      ''|'#'*) continue ;;
    esac
    code --install-extension "$ext" --force >/dev/null
  done < "$extensions_file"
}

mkdir -p "$user_dir"
link_file "$settings_file" "$user_dir/settings.json"

install_extensions
