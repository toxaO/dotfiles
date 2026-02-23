# nvimのddc/mocword用辞書パス
export MOCWORD_DATA=~/.config/mocword/mocword.sqlite

case ${OSTYPE} in
  darwin*)
    # pyenv
    if [ "$(uname -m)" = "arm64" ]; then
      export PYENV_ROOT="$HOME/.pyenv_arm64"
      export PATH="$PYENV_ROOT/bin:$PATH"
    else
      export PYENV_ROOT="$HOME/.pyenv_x86"
      export PATH="$PYENV_ROOT/bin:$PATH"
    fi
    command -v pyenv >/dev/null && eval "$(pyenv init -)"
    command -v pyenv >/dev/null && eval "$(pyenv init --path)"

    # Homebrew
    if [[ $(uname -m) == arm64 ]]; then
      [ -x /opt/homebrew/bin/brew ] && eval "$(/opt/homebrew/bin/brew shellenv)"
      alias vim='/opt/homebrew/bin/vim'
      alias nvim='/opt/homebrew/bin/nvim'
      export PATH="/opt/homebrew/opt/curl/bin:$PATH"
      export LDFLAGS="-L/opt/homebrew/opt/curl/lib"
      export CPPFLAGS="-I/opt/homebrew/opt/curl/include"
      export PKG_CONFIG_PATH="/opt/homebrew/opt/curl/lib/pkgconfig"
    else
      [ -x /usr/local/bin/brew ] && eval "$(/usr/local/bin/brew shellenv)"
      alias vim='/usr/local/bin/vim'
      alias nvim='/usr/local/bin/nvim'
      export PATH="/usr/local/opt/curl/bin:$PATH"
      export LDFLAGS="-L/usr/local/opt/curl/lib"
      export CPPFLAGS="-I/usr/local/opt/curl/include"
      export PKG_CONFIG_PATH="/usr/local/opt/curl/lib/pkgconfig"
    fi
    ;;

    linux*)
    # ここに Linux 向けの設定
    export PATH="$PATH:/opt/nvim/"
    # linux*) ブロック内
    if [[ -r /proc/version && $(</proc/version) == *Microsoft* ]];
    then LS_COLORS="${LS_COLORS}:ow=01;34";
    export LS_COLORS
    fi
    ;;
esac
