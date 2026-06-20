# ~/.zsh/prompt.zsh
# 対話シェル以外では何もしない
[[ -o interactive ]] || return 0

# --- virtualenv info ---
virtualenv_info() {
  local pyicon=$'\U000F0320 '
  local color=$'%{\e[38;5;'; local green=$'114m%}'; local yellow=$'227m%}'; local reset=$'%{\e[0m%}'
  if [[ -n $VIRTUAL_ENV ]]; then
    local venv_name="$(basename "$VIRTUAL_ENV")"
    local parent_name="$(basename "$(dirname "$VIRTUAL_ENV")")"
    if [[ $VIRTUAL_ENV == "$HOME/.venv" ]]; then
      echo "${color}${green}${pyicon}${reset}"
    elif [[ $venv_name == ".venv" ]]; then
      echo "${color}${yellow}${pyicon}${parent_name}${reset}"
    else
      echo "${color}${yellow}${pyicon}${venv_name}${reset}"
    fi
  elif [[ -n $PYENV_VERSION ]]; then
    echo "${color}${yellow}${pyicon}${PYENV_VERSION}${reset}"
  elif [[ -n $CONDA_DEFAULT_ENV ]]; then
    echo "${color}${yellow}${pyicon}${CONDA_DEFAULT_ENV}${reset}"
  fi
}

# --- git rprompt ---
rprompt-git-current-branch() {
  local branch=$'\ue0a0'
  local color='%{\e[38;5;'; local green='114m%}'; local yellow='227m%}'; local red='001m%}'; local blue='033m%}'; local reset='%{\e[0m%}'
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local name
  name=$(git symbolic-ref --short -q HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null || echo 'detached')
  local has_unstaged=0 has_staged=0 has_untracked=0
  git diff --quiet --ignore-submodules --     || has_unstaged=1
  git diff --cached --quiet --ignore-submodules -- || has_staged=1
  [[ -n $(git ls-files --others --exclude-standard 2>/dev/null) ]] && has_untracked=1
  local mark
  if ((has_unstaged)); then
    mark="${color}${red}${branch}+"
  elif ((has_staged)); then
    mark="${color}${yellow}${branch}!"
  elif ((has_untracked)); then
    mark="${color}${red}${branch}?"
  else
    mark="${color}${green}${branch}"
  fi
  echo "${mark}${name}${reset}"
}

# --- left prompt ---
left-prompt() {
  local clock_t=$'217m%}' clock_b=$'016m%}' name_t=$'153m%}' name_b=$'016m%}'
  local machine_t=$'141m%}' machine_b=$'016m%}' path_t=$'255m%}' path_b=$'031m%}'
  local text_color=$'%{\e[38;5;' back_color=$'%{\e[30;48;5;' reset=$'%{\e[0m%}' sharp=$'\uE0B0'
  case "$HOST" in tokuserver) machine_t='014m%}'; machine_b='016m%}';; esac
  case "$HOST" in tokuserver3) machine_t='014m%}'; machine_b='016m%}';; esac
  local clock="${back_color}${clock_b}${text_color}${clock_t}"
  local user="${back_color}${name_b}${text_color}${name_t}"
  local machine="${back_color}${machine_b}${text_color}${machine_t}"
  local dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${clock}%* ${user}%n %# ${reset}${machine}%m${back_color}${path_b}${text_color}${name_b}${sharp} ${dir}%~${reset}${text_color}${path_b}${sharp}${reset}
%{%F{cyan}%}❯%{%F{magenta}%}❯%{%F{blue}%}❯ "
}

# --- apply ---
setopt prompt_subst
RPROMPT='$(virtualenv_info) $(rprompt-git-current-branch)'
PROMPT='$(left-prompt)'

# コマンドの実行ごとに改行(定義しておくだけで効果アリ)
function precmd() {
    # Print a newline before the prompt, unless it's the first prompt in the process.
    if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
        NEW_LINE_BEFORE_PROMPT=1
    elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
        echo ""
    fi
}
