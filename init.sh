#!/bin/sh

set -eu

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
ZDOTDIR="${ZDOTDIR:-$HOME}"
ZPREZTO_DIR="$ZDOTDIR/.zprezto"

clone_or_update() {
  repo_url=$1
  dest_dir=$2
  recursive=${3:-}

  if [ -d "$dest_dir/.git" ]; then
    git -C "$dest_dir" pull --ff-only
    if [ "$recursive" = recursive ]; then
      git -C "$dest_dir" submodule update --init --recursive
    fi
  elif [ -e "$dest_dir" ]; then
    echo "skip clone: $dest_dir already exists and is not a git repository" >&2
  else
    if [ "$recursive" = recursive ]; then
      git clone --recursive "$repo_url" "$dest_dir"
    else
      git clone "$repo_url" "$dest_dir"
    fi
  fi
}

link_file() {
  src=$1
  dest=$2

  if [ -L "$dest" ] || [ ! -e "$dest" ]; then
    ln -sfn "$src" "$dest"
  else
    echo "skip link: $dest already exists and is not a symlink" >&2
  fi
}

# download/update dotfiles
clone_or_update https://github.com/toxaO/dotfiles.git "$DOTFILES_DIR"

# install zsh
sudo apt-get update
sudo apt-get install -y zsh

# install zprezto
clone_or_update https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR" recursive

# change shell
# $(which zsh)

# init zprezto
for rcfile in "$ZPREZTO_DIR"/runcoms/*; do
  [ -f "$rcfile" ] || continue
  [ "$(basename "$rcfile")" = README.md ] && continue
  link_file "$rcfile" "$ZDOTDIR/.$(basename "$rcfile")"
done

link_file "$DOTFILES_DIR/prezto/zpreztorc" "$ZDOTDIR/.zpreztorc"

link_file "$DOTFILES_DIR/zsh/zshrc" "$ZDOTDIR/.zshrc"

# set login shell
if [ "${SHELL:-}" != "$(command -v zsh)" ]; then
  chsh -s "$(command -v zsh)" || echo "warning: failed to change login shell" >&2
fi


# deno
# 事前にunzipをインストールしておく
sudo apt install -y unzip

# denoをインストールする
curl -fsSL https://deno.land/x/install/install.sh | sh

# luaのインストール
sudo apt install -y lua5.3

#.configのリンク作成
mkdir -p "$HOME/.config"
link_file "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
link_file "$DOTFILES_DIR/tmux/tmux.conf" "$HOME/.tmux.conf"

# git
git config --global user.email "material.xyz.44@gmail.com"
git config --global user.name "toxaO"

# rust install
PATH="$HOME/.cargo/bin:$PATH"
if command -v rustup >/dev/null 2>&1; then
  rustup update
else
  curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

# mocword
sudo apt-get update
sudo apt-get install -y build-essential
if ! command -v mocword >/dev/null 2>&1; then
  cargo install mocword
fi

mkdir -p "$HOME/.config/mocword"
if [ ! -f "$HOME/.config/mocword/mocword.sqlite" ]; then
  curl -sLJO https://github.com/high-moctane/mocword-data/releases/download/eng20200217/mocword.sqlite.gz
  gunzip -f mocword.sqlite.gz
  mv "$HOME/mocword.sqlite" "$HOME/.config/mocword"
fi

# Masonのpyrightを入れるためのnpmのインストール
sudo apt install -y nodejs npm


# cdr
mkdir -p $HOME/.cache/shell/

# luacheck
sudo apt install -y luarocks
sudo apt install -y liblua5.3-dev
if ! command -v luacheck >/dev/null 2>&1; then
  sudo luarocks install luacheck
fi

# ripgrep install
sudo apt install -y ripgrep
