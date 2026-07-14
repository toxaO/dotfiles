# ~/.zsh/prompt.zsh
# 対話シェル以外では何もしない
[[ -o interactive ]] || return 0

autoload -Uz add-zsh-hook

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

prompt-machine-label() {
  local -a ssh_connection_parts
  ssh_connection_parts=(${=SSH_CONNECTION})
  local ssh_host_ip="${ssh_connection_parts[3]}"
  local host_name="${HOST:-$(hostname -s 2>/dev/null || hostname 2>/dev/null)}"
  local host_name_lc="${(L)host_name}"

  if [[ "$OSTYPE" == darwin* ]]; then
    echo "macbook"
  elif [[ -n "$WSL_DISTRO_NAME" ]] || [[ -r /proc/version && ${(L)$(</proc/version)} == *microsoft* ]]; then
    echo "wsl"
  elif [[ "$ssh_host_ip" == "192.168.86.40" ]]; then
    echo "cloud"
  elif [[ "$ssh_host_ip" == "192.168.86.39" ]]; then
    echo "kvm"
  elif [[ "$host_name_lc" == hermes* ]]; then
    echo "hermes"
  elif [[ "$host_name_lc" == tokuwin* ]]; then
    echo "win"
  else
    echo "${host_name:-other}"
  fi
}

prompt-machine-colors() {
  local machine_label="$1"
  case "$machine_label" in
    macbook) echo "195m%} 016m%}" ;;
    win) echo "220m%} 016m%}" ;;
    wsl) echo "114m%} 016m%}" ;;
    cloud) echo "051m%} 016m%}" ;;
    kvm) echo "203m%} 016m%}" ;;
    hermes) echo "120m%} 022m%}" ;;
    *) echo "183m%} 016m%}" ;;
  esac
}

# --- left prompt ---
left-prompt() {
  local clock_t=$'217m%}' clock_b=$'016m%}' name_t=$'153m%}' name_b=$'016m%}'
  local machine_t=$'141m%}' machine_b=$'016m%}' path_t=$'255m%}' path_b=$'031m%}'
  local text_color=$'%{\e[38;5;' back_color=$'%{\e[30;48;5;' reset=$'%{\e[0m%}' sharp=$'\uE0B0'
  local machine_label machine_colors
  machine_label="$(prompt-machine-label)"
  machine_colors=(${=$(prompt-machine-colors "$machine_label")})
  machine_t="${machine_colors[1]}"
  machine_b="${machine_colors[2]}"
  local clock="${back_color}${clock_b}${text_color}${clock_t}"
  local user="${back_color}${name_b}${text_color}${name_t}"
  local machine="${back_color}${machine_b}${text_color}${machine_t}"
  local dir="${back_color}${path_b}${text_color}${path_t}"
  echo "${clock}%* ${user}%n %# ${reset}${machine}${machine_label}${back_color}${path_b}${text_color}${name_b}${sharp} ${dir}%~${reset}${text_color}${path_b}${sharp}${reset}
%{%F{cyan}%}❯%{%F{magenta}%}❯%{%F{blue}%}❯ "
}

# --- apply ---
setopt prompt_subst
RPROMPT='$(virtualenv_info) $(rprompt-git-current-branch)'
PROMPT='$(left-prompt)'

# コマンドの実行ごとに改行(定義しておくだけで効果アリ)
prompt-precmd-newline() {
  # Print a newline before the prompt, unless it's the first prompt in the process.
  if [ -z "$NEW_LINE_BEFORE_PROMPT" ]; then
    NEW_LINE_BEFORE_PROMPT=1
  elif [ "$NEW_LINE_BEFORE_PROMPT" -eq 1 ]; then
    echo ""
  fi
}

add-zsh-hook precmd prompt-precmd-newline
