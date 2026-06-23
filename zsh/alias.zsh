# dir alias
alias .f='cd ~/dotfiles'
alias pr='project_root'

# windows wakeonlan
alias wakewin='ssh toku@toku3 wakeonlan f0:2f:74:4d:9b:7c'

# vim / nvim
alias nv='nvim'
alias ns='nvim -S'
alias nf='f(){ local f; f=$(fzf -1 -0) || return; nvim "$f"; }; f'
alias vf='f(){ local f; f=$(fzf -1 -0) || return; vim "$f"; }; f'

# コマンド
if [[ -o interactive ]]; then
  alias rm='rm -I'   # 対話時は確認付き
else
  alias rm='rm'      # 非対話（スクリプトなど）はそのまま
fi

# python alias
alias pip='pip3'
alias py='python3'
alias da='vadeactivate'

# tmux
alias tm='tmux_start'
alias .t='tmux_reload'
alias tls='tmux list-sessions'
alias ta='tmux attach -t'
alias tn='tmux new -A -s'

# zsh
alias .z='source ~/dotfiles/zsh/zshrc'

# git関連alia
alias co='git checkout'
alias br='git branch'
alias com='git checkout main'
alias cod='git checkout develop'
alias coC='git checkout Codex'
alias gl='git log --oneline -n 10'
alias ga='git add .'
alias gaa='git add -A'
alias gc='git commit -m'
alias gs='git status'
alias gm='git merge'
alias gls='git ls-files'
alias gf='git fetch'
alias gp='git push'
alias gpl='git pull'
alias gcl='git clone'
alias gcb='git checkout -b'
alias gpo='git push origin'
alias gr='git remote -v'
alias lg='lazygit'

# apple siricon アーキテクチャエイリアス
alias x86='arch -x86_64 zsh'
alias arm='arch -arm64e zsh'

#.DS_Store消去
alias rmDS='find . -name ".DS_Store" -type f -ls -delete'

# Codex
alias cr='codex resume'

# Obsidian drafts sync
alias obdp='ob_drafts_pull'
alias obdu='ob_drafts_push'
# n = rsync --dry-run
alias obdn='ob_drafts_dry_run'
# s = status
alias obds='ob_drafts_status'
