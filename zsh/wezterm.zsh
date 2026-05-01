[[ -o interactive ]] || return 0
[[ "${TERM_PROGRAM:-}" == "WezTerm" || -n "${WEZTERM_EXECUTABLE:-}" ]] || return 0

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
}

__wezterm_precmd() {
  local last_status=$?

  __wezterm_set_cwd
  __wezterm_set_user_var "WEZTERM_PROG" ""
  __wezterm_set_user_var "WEZTERM_USER" "${USER:-$(id -un 2>/dev/null)}"
  __wezterm_set_user_var "WEZTERM_HOST" "${HOST:-$(hostname 2>/dev/null)}"
  __wezterm_set_user_var "WEZTERM_IN_TMUX" "$([[ -n "${TMUX:-}" ]] && printf 1 || printf 0)"

  __wezterm_osc "133;D;${last_status}"
  __wezterm_osc "133;A"
}

__wezterm_preexec() {
  local cmd="$1"
  __wezterm_set_user_var "WEZTERM_PROG" "$cmd"
  __wezterm_osc "133;C"
}

__wezterm_prompt_end() {
  printf '\033]133;B\007'
}

add-zsh-hook precmd __wezterm_precmd
add-zsh-hook preexec __wezterm_preexec
add-zsh-hook chpwd __wezterm_set_cwd

PROMPT+='%{$(__wezterm_prompt_end)%}'
