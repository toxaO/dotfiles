[[ -o interactive ]] || return 0
[[ "${TERM_PROGRAM:-}" == "WezTerm" || -n "${WEZTERM_EXECUTABLE:-}" || -n "${WEZTERM_PANE:-}" || -n "${TMUX:-}" ]] || return 0

autoload -Uz add-zsh-hook

__wezterm_osc() {
  local payload="$1"
  if [[ -n "${TMUX:-}" ]]; then
    printf '\033Ptmux;\033\033]%s\007\033\\' "$payload"
  else
    printf '\033]%s\007' "$payload"
  fi
}

__wezterm_set_user_var() {
  local name="$1"
  local value="$2"
  command -v base64 >/dev/null 2>&1 || return 0
  local encoded
  encoded=$(printf '%s' "$value" | base64 | tr -d '\r\n')
  __wezterm_osc "1337;SetUserVar=${name}=${encoded}"
}

__wezterm_set_cwd() {
  local host path
  host="${HOST:-$(hostname -s 2>/dev/null || hostname 2>/dev/null || printf localhost)}"
  path="${PWD// /%20}"
  __wezterm_osc "7;file://${host}${path}"
  __wezterm_set_user_var "WEZTERM_CWD_SHORT" "$(__wezterm_short_cwd)"
}

__wezterm_short_cwd() {
  local path="$PWD"
  path="${path/#$HOME/~}"
  printf '%s' "$path"
}

__wezterm_tmux_session() {
  [[ -n "${TMUX:-}" ]] || return 0
  command -v tmux >/dev/null 2>&1 || return 0
  tmux display-message -p '#S' 2>/dev/null
}

__wezterm_tmux_neighbor_session() {
  local direction="$1"
  [[ -n "${TMUX:-}" ]] || return 0
  command -v tmux >/dev/null 2>&1 || return 0

  local current sessions idx target_idx
  current="$(tmux display-message -p '#S' 2>/dev/null)" || return 0
  sessions=("${(@f)$(tmux list-sessions -F '#S' 2>/dev/null)}")
  (( ${#sessions} > 1 )) || return 0

  for (( idx = 1; idx <= ${#sessions}; idx++ )); do
    if [[ "${sessions[$idx]}" == "$current" ]]; then
      if [[ "$direction" == "prev" ]]; then
        target_idx=$(( idx == 1 ? ${#sessions} : idx - 1 ))
      else
        target_idx=$(( idx == ${#sessions} ? 1 : idx + 1 ))
      fi
      printf '%s' "${sessions[$target_idx]}"
      return 0
    fi
  done
}

__wezterm_update_tmux_status() {
  [[ -n "${TMUX:-}" ]] || return 0
  local script="$HOME/dotfiles/tmux/scripts/update_wezterm_status.sh"
  [[ -x "$script" ]] || return 0
  "$script" >/dev/null 2>&1
}

__wezterm_precmd() {
  local last_status=$?

  __wezterm_set_cwd
  __wezterm_update_tmux_status
  __wezterm_set_user_var "WEZTERM_PROG" ""
  __wezterm_set_user_var "WEZTERM_USER" "${USER:-$(id -un 2>/dev/null)}"
  __wezterm_set_user_var "WEZTERM_HOST" "${HOST:-$(hostname 2>/dev/null)}"
  __wezterm_set_user_var "WEZTERM_IN_TMUX" "$([[ -n "${TMUX:-}" ]] && printf 1 || printf 0)"
  __wezterm_set_user_var "WEZTERM_TMUX_SESSION" "$(__wezterm_tmux_session)"
  __wezterm_set_user_var "WEZTERM_TMUX_SESSION_PREV" "$(__wezterm_tmux_neighbor_session prev)"
  __wezterm_set_user_var "WEZTERM_TMUX_SESSION_NEXT" "$(__wezterm_tmux_neighbor_session next)"

  __wezterm_osc "133;D;${last_status}"
  __wezterm_osc "133;A"
}

__wezterm_preexec() {
  local cmd="$1"
  __wezterm_set_user_var "WEZTERM_PROG" "$cmd"
  __wezterm_osc "133;C"
}

__wezterm_prompt_end() {
  __wezterm_osc "133;B"
}

add-zsh-hook precmd __wezterm_precmd
add-zsh-hook preexec __wezterm_preexec
add-zsh-hook chpwd __wezterm_set_cwd
add-zsh-hook chpwd __wezterm_update_tmux_status

PROMPT+='%{$(__wezterm_prompt_end)%}'
