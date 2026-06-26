# nvimのddc/mocword用辞書パス
export MOCWORD_DATA=~/.config/mocword/mocword.sqlite

apply_completion_colors() {
  local colors="${LS_COLORS:-}"

  zstyle ':completion:*' list-colors "${(s.:.)colors}"
  zstyle ':completion:*:default' list-colors "${(s.:.)colors}"
}

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
    command -v pyenv >/dev/null && eval "$(pyenv init --no-rehash -)"
    command -v pyenv >/dev/null && eval "$(pyenv init --no-rehash --path)"

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
    export PATH="$PATH:/opt/nvim/bin"
    export LD_LIBRARY_PATH=/usr/lib/wsl/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}

    if command -v dircolors >/dev/null 2>&1; then
      eval "$(dircolors -b)"
    fi

    if [[ -r /proc/version && ${(L)$(</proc/version)} == *microsoft* ]]; then
      # DrvFS directories under /mnt/* are often seen as world-writable.
      # Color them like normal directories to keep ls and completion readable.
      LS_COLORS=$(print -r -- "$LS_COLORS" | sed -E \
        -e 's/(^|:)ow=[^:]*/\1ow=01;34/g' \
        -e 's/(^|:)tw=[^:]*/\1tw=01;34/g' \
        -e 's/(^|:)st=[^:]*/\1st=01;34/g')
      export LS_COLORS
    fi
    ;;
esac

apply_completion_colors
