# 補完で小文字でも大文字にマッチさせる
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補を詰めて表示
setopt list_packed
# 補完候補一覧をカラー表示
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS:-}
zmodload zsh/complist
zstyle ':completion:*' menu select
# コマンドのスペルを訂正
setopt correct
# ビープ音を鳴らさない
setopt no_beep
# グロブ表現避け (*等)
setopt nonomatch
# ヒストリ関連オプション
setopt inc_append_history share_history hist_ignore_all_dups hist_reduce_blanks
#コマンド履歴保存数
HISTFILE=~/.histfile
HISTSIZE=100000
SAVEHIST=100000

#基本エディタの設定
export EDITOR=nvim
export VISUAL=$EDITOR

# cdr の設定
autoload -Uz add-zsh-hook chpwd_recent_dirs cdr
add-zsh-hook chpwd chpwd_recent_dirs
zstyle ':completion:*' recent-dirs-insert both
zstyle ':chpwd:*' recent-dirs-max 500
zstyle ':chpwd:*' recent-dirs-default true
zstyle ':chpwd:*' recent-dirs-file "$HOME/.cache/shell/chpwd-recent-dirs"
zstyle ':chpwd:*' recent-dirs-pushd true
