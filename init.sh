#!/bin/zsh


# download dotfiles
cd $HOME
git clone https://github.com/toxaO/dotfiles.git

# install zsh
sudo apt-get install zsh || y

# install zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"

# change shell
# $(which zsh)

# init zprezto
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done

rm .zpreztorc
ln -s dotfiles/prezto/zpreztorc .zpreztorc

rm .zshrc
ln -s dotfiles/zsh/zshrc .zshrc

# set login shell
 chsh -s $(which zsh)


# deno
# 事前にunzipをインストールしておく
sudo apt install unzip

# denoをインストールする
curl -fsSL https://deno.land/x/install/install.sh | sh

# luaのインストール
sudo apt install lua5.3

#.configのリンク作成
mkdir -p $HOME/.config
ln -s $HOME/dotfiles/nvim $HOME/.config/nvim
ln -s $HOME/dotfiles/tmux/tmux.conf $HOME/.tmux.conf

# git
git config --global user.email "material.xyz.44@gmail.com"
git config --global user.name "toxaO"

# rust install
curl https://sh.rustup.rs -sSf | sh

# mocword
sudo apt-get update
sudo apt-get install build-essential
cargo install mocword

curl -sLJO https://github.com/high-moctane/mocword-data/releases/download/eng20200217/mocword.sqlite.gz
gunzip mocword.sqlite.gz
mkdir -p $HOME/.config/mocword
mv $HOME/mocword.sqlite $HOME/.config/mocword

# Masonのpyrightを入れるためのnpmのインストール
sudo apt install -y nodejs npm


# cdr
mkdir -p $HOME/.cache/shell/

# luacheck
sudo apt install luarocks
sudo apt install liblua5.3-dev
sudo luarocks install luacheck

# ripgrep install
sudo apt install ripgrep
