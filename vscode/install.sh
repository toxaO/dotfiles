#!/bin/sh

set -eu

case "$(uname -s)" in
  Darwin)
    script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
    exec "$script_dir/mac/install.sh"
    ;;
  *)
    echo "use vscode/windows/install.ps1 on Windows" >&2
    exit 1
    ;;
esac
