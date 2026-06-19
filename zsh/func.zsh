#--------------------------------------------------
#256色の確認関数:colorlist
#--------------------------------------------------
colorlist() {
	for color in {000..015}; do
		print -nP "%F{$color}$color %f"
	done
	printf "\n"
	for color in {016..255}; do
		print -nP "%F{$color}$color %f"
		if [ $(($((color-16))%6)) -eq 5 ]; then
			printf "\n"
		fi
	done
}

#--------------------------------------------------
# cd project root
#--------------------------------------------------
project_root() {
  local top
  top="$(git rev-parse --show-toplevel 2>/dev/null)" || return
  cd "$top" || return
}

#--------------------------------------------------
# qmk補完
#--------------------------------------------------
if [ -e ~/repos/qmk_firmware ]; then
autoload -Uz bashcompinit && bashcompinit
source ~/github/qmk/qmk_firmware/util/qmk_tab_complete.sh
fi

#--------------------------------------------------
# tmux
#--------------------------------------------------
chpwd() {
  if [ -n "$TMUX" ]; then
    tmux refresh-client -S
  fi
}

tmux_reload() {
  local conf="$HOME/dotfiles/tmux/tmux.conf"
  if ! command -v tmux >/dev/null; then
    echo "tmux not found" >&2
    return 1
  fi
  if [ -n "$TMUX" ]; then
    tmux source-file "$conf" >/dev/null || return 1
    if [ -x "$HOME/dotfiles/tmux/scripts/update_keybinds_notes.sh" ]; then
      "$HOME/dotfiles/tmux/scripts/update_keybinds_notes.sh"
    fi
    tmux display-message "Reloaded: $conf"
  else
    tmux source-file "$conf" || return 1
    if [ -x "$HOME/dotfiles/tmux/scripts/update_keybinds_notes.sh" ]; then
      "$HOME/dotfiles/tmux/scripts/update_keybinds_notes.sh"
    fi
    echo "Reloaded: $conf"
  fi
}

tmux_start() {
  if ! command -v tmux >/dev/null; then
    echo "tmux not found" >&2
    return 1
  fi
  if [ -n "$TMUX" ]; then
    echo "already in tmux" >&2
    return 1
  fi

  local sessions choice name
  sessions=("${(@f)$(tmux list-sessions -F '#S' 2>/dev/null)}")

  if (( ${#sessions} > 0 )); then
    if command -v fzf >/dev/null; then
      local selected action target
      selected="$(
        {
          printf 'new\t+ Create new session\n'
          for name in "${sessions[@]}"; do
            printf 'attach\t%s\n' "$name"
          done
        } | fzf --prompt="tmux> " --height=40% --with-nth=2.. \
          --header="Enter: attach/create. Inside tmux help: Prefix(Ctrl-j) H."
      )"

      [[ -z "$selected" ]] && return 0
      action="${selected%%$'\t'*}"
      target="${selected#*$'\t'}"

      case "$action" in
        attach)
          tmux attach -t "$target"
          return
          ;;
        new)
          ;;
      esac
    else
      echo "Choose how to start tmux:"
      select choice in "Choose existing (choose-tree)" "Create new session"; do
        case "$choice" in
          "Choose existing (choose-tree)")
            tmux attach -t "${sessions[1]}" \; choose-tree -Zs
            return
            ;;
          "Create new session")
            break
            ;;
          *)
            echo "Invalid selection."
            ;;
        esac
      done
    fi
  fi

  local base_dir picked_dir dir_roots existing_roots root
  base_dir="$HOME"

  if [[ -n "${TMUX_SESSION_DIR_ROOTS:-}" ]]; then
    dir_roots=("${(@s.:.)TMUX_SESSION_DIR_ROOTS}")
  else
    dir_roots=("$HOME")
    [[ -d /mnt/c/Users ]] && dir_roots+=("/mnt/c/Users")
    [[ -d /mnt/d ]] && dir_roots+=("/mnt/d")
  fi
  existing_roots=()
  for root in "${dir_roots[@]}"; do
    [[ -d "$root" ]] && existing_roots+=("${root:A}")
  done
  dir_roots=("${(@u)existing_roots}")
  (( ${#dir_roots} > 0 )) || dir_roots=("$base_dir")

  if command -v fzf >/dev/null; then
    if command -v fd >/dev/null; then
      picked_dir="$(fd -t d -H --exclude .git --exclude node_modules --exclude .cache --max-depth 3 . "${dir_roots[@]}" | \
        fzf --prompt="Dir> " --height=40% \
        --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
        --bind="ctrl-d:reload(TMUX_SESSION_DIR_ROOTS=\"${TMUX_SESSION_DIR_ROOTS:-}\" sh \"$HOME/dotfiles/tmux/scripts/new_session_fzf.sh\" --list-dirs deep)" \
        --bind="ctrl-s:reload(TMUX_SESSION_DIR_ROOTS=\"${TMUX_SESSION_DIR_ROOTS:-}\" sh \"$HOME/dotfiles/tmux/scripts/new_session_fzf.sh\" --list-dirs shallow)")"
    else
      picked_dir="$(find "${dir_roots[@]}" -maxdepth 3 -type d 2>/dev/null | \
        fzf --prompt="Dir> " --height=40% \
        --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
        --bind="ctrl-d:reload(TMUX_SESSION_DIR_ROOTS=\"${TMUX_SESSION_DIR_ROOTS:-}\" sh \"$HOME/dotfiles/tmux/scripts/new_session_fzf.sh\" --list-dirs deep)" \
        --bind="ctrl-s:reload(TMUX_SESSION_DIR_ROOTS=\"${TMUX_SESSION_DIR_ROOTS:-}\" sh \"$HOME/dotfiles/tmux/scripts/new_session_fzf.sh\" --list-dirs shallow)")"
    fi
  else
    vared -p "Directory (default: $base_dir): " picked_dir
  fi

  if [[ -z "$picked_dir" ]]; then
    picked_dir="$base_dir"
  fi

  local dir_name date_suffix
  dir_name="$(basename "$picked_dir")"
  dir_name="${dir_name// /_}"
  dir_name="${dir_name[1,10]}"
  date_suffix="$(date +%m%d)"
  name="${dir_name}_${date_suffix}"

  tmux new -A -s "$name" -c "$picked_dir"
}

tmux_keybinds_update() {
  local script="$HOME/dotfiles/tmux/scripts/update_keybinds_notes.sh"
  if [ ! -x "$script" ]; then
    echo "not executable: $script" >&2
    return 1
  fi
  "$script"
}

zsh_cmds_update() {
  local script="$HOME/dotfiles/zsh/scripts/update_commands_notes.sh"
  if [ ! -x "$script" ]; then
    echo "not executable: $script" >&2
    return 1
  fi
  "$script"
}

zsh_cmds_menu() {
  local script="$HOME/dotfiles/zsh/scripts/commands_menu.sh"
  if [ ! -x "$script" ]; then
    echo "not executable: $script" >&2
    return 1
  fi
  "$script"
}

ob_drafts_pull() {
  local remote="${OB_DRAFTS_REMOTE:-toku}"
  local remote_dir="${OB_DRAFTS_REMOTE_DIR:-/home/tokumasa/ob_drafts}"
  local local_dir="${OB_DRAFTS_DIR:-$HOME/ob_drafts}"

  mkdir -p "$local_dir" || return 1
  rsync -rtv --itemize-changes --no-perms --no-owner --no-group \
    "$remote:$remote_dir/" "$local_dir/"
}

ob_drafts_push() {
  local remote="${OB_DRAFTS_REMOTE:-toku}"
  local remote_dir="${OB_DRAFTS_REMOTE_DIR:-/home/tokumasa/ob_drafts}"
  local local_dir="${OB_DRAFTS_DIR:-$HOME/ob_drafts}"

  mkdir -p "$local_dir" || return 1
  rsync -rtv --itemize-changes --no-perms --no-owner --no-group \
    "$local_dir/" "$remote:$remote_dir/"
}

ob_drafts_dry_run() {
  local remote="${OB_DRAFTS_REMOTE:-toku}"
  local remote_dir="${OB_DRAFTS_REMOTE_DIR:-/home/tokumasa/ob_drafts}"
  local local_dir="${OB_DRAFTS_DIR:-$HOME/ob_drafts}"

  mkdir -p "$local_dir" || return 1
  rsync -rtvn --itemize-changes --no-perms --no-owner --no-group \
    "$remote:$remote_dir/" "$local_dir/"
}

ob_drafts_status() {
  local remote="${OB_DRAFTS_REMOTE:-toku}"
  local remote_dir="${OB_DRAFTS_REMOTE_DIR:-/home/tokumasa/ob_drafts}"
  local local_dir="${OB_DRAFTS_DIR:-$HOME/ob_drafts}"

  echo "local : $local_dir"
  echo "remote: $remote:$remote_dir"
  echo ""
  echo "[remote -> local dry-run]"
  mkdir -p "$local_dir" || return 1
  rsync -rtvn --itemize-changes --no-perms --no-owner --no-group \
    "$remote:$remote_dir/" "$local_dir/"
}

unalias cx 2>/dev/null

_agents_dotfiles_dir() {
  local dir="$HOME/dotfiles"

  if [ ! -d "$dir" ]; then
    echo "dotfiles directory not found: $dir" >&2
    return 1
  fi

  print -r -- "${dir:A}"
}

_agents_write_main() {
  local dest="$1"
  local dotfiles_dir base

  dotfiles_dir="$(_agents_dotfiles_dir)" || return 1
  base="$dotfiles_dir/templates/AGENTS_BASE.md"
  if [ ! -f "$base" ]; then
    echo "base template not found: $base" >&2
    return 1
  fi

  {
    print -r -- "# AGENTS.md"
    print -r -- ""
    print -r -- "@$base"
    print -r -- "@./AGENTS_PROJECT.md"
  } > "$dest"
}

agents_template() {
  local dotfiles_dir project_template dest_dir main project
  dotfiles_dir="$(_agents_dotfiles_dir)" || return 1
  project_template="$dotfiles_dir/templates/AGENTS_PROJECT.md"
  dest_dir="${1:-$PWD}"

  if [[ "$dest_dir" == */AGENTS.md ]]; then
    dest_dir="${dest_dir:h}"
  fi

  main="$dest_dir/AGENTS.md"
  project="$dest_dir/AGENTS_PROJECT.md"

  if [ ! -f "$project_template" ]; then
    echo "project template not found: $project_template" >&2
    return 1
  fi

  if [ -e "$main" ] || [ -e "$project" ]; then
    echo "already exists: $main or $project" >&2
    return 1
  fi

  cp "$project_template" "$project" || return 1
  _agents_write_main "$main" || return 1
  echo "created: $main"
  echo "created: $project"
}

agents_migrate() {
  local dest_dir main project
  dest_dir="${1:-$PWD}"

  if [[ "$dest_dir" == */AGENTS.md ]]; then
    dest_dir="${dest_dir:h}"
  fi

  main="$dest_dir/AGENTS.md"
  project="$dest_dir/AGENTS_PROJECT.md"

  if [ ! -f "$main" ]; then
    echo "not found: $main" >&2
    return 1
  fi

  if [ -e "$project" ]; then
    echo "already exists: $project" >&2
    return 1
  fi

  cp "$main" "$project" || return 1
  _agents_write_main "$main" || return 1
  echo "migrated: $main"
  echo "created: $project"
}

agents_refresh() {
  local dest_dir main project
  dest_dir="${1:-$PWD}"

  if [[ "$dest_dir" == */AGENTS.md ]]; then
    dest_dir="${dest_dir:h}"
  fi

  main="$dest_dir/AGENTS.md"
  project="$dest_dir/AGENTS_PROJECT.md"

  if [ ! -f "$project" ]; then
    echo "not found: $project" >&2
    return 1
  fi

  _agents_write_main "$main" || return 1
  echo "refreshed: $main"
}

function cx {
  local target="$PWD/AGENTS.md"
  local project="$PWD/AGENTS_PROJECT.md"
  local agent_editor="${AGENTS_EDITOR:-nvim}"

  if [ ! -f "$target" ]; then
    agents_template "$PWD" || return 1
    "$agent_editor" "$project" || return 1
  fi

  codex "$@"
}

#--------------------------------------------------
# Hermes
#--------------------------------------------------
_hermes_ollama_wait() {
  local url="${HERMES_OLLAMA_HEALTH_URL:-http://127.0.0.1:11434/api/tags}"
  local timeout="${HERMES_OLLAMA_START_TIMEOUT:-20}"
  local i

  for (( i = 1; i <= timeout; i++ )); do
    if curl -fsS "$url" >/dev/null 2>&1; then
      return 0
    fi
    sleep 1
  done

  echo "ollama did not become ready: $url" >&2
  return 1
}

hermes_ollama_tui() {
  local model="${HERMES_OLLAMA_MODEL:-qwen3.6:27b}"
  local log="${HERMES_OLLAMA_LOG:-/tmp/ollama-serve.log}"

  if ! command -v hermes >/dev/null; then
    echo "hermes not found" >&2
    return 1
  fi
  if ! command -v ollama >/dev/null; then
    echo "ollama not found" >&2
    return 1
  fi

  if ! curl -fsS http://127.0.0.1:11434/api/tags >/dev/null 2>&1; then
    echo "starting ollama serve..."
    ollama serve > "$log" 2>&1 &
    disown
    _hermes_ollama_wait || return 1
  fi

  hermes chat --tui --provider custom --model "$model" "$@"
}

hermes_openai_tui() {
  local provider="${HERMES_OPENAI_PROVIDER:-openai}"
  local model="${HERMES_OPENAI_MODEL:-gpt-5.3-codex}"

  if ! command -v hermes >/dev/null; then
    echo "hermes not found" >&2
    return 1
  fi
  if [[ "$provider" == "openai" && -z "${OPENAI_API_KEY:-}" ]]; then
    echo "OPENAI_API_KEY is not set" >&2
    return 1
  fi

  hermes chat --tui --provider "$provider" --model "$model" "$@"
}

#--------------------------------------------------
# python
#--------------------------------------------------
# venvの作成関数
function mkvenv() {
  local venv_name=${1:-.venv}
  python3 -m venv "$venv_name" || return
  if [[ ! $(basename "$PWD") == $USER && -z ${1} ]]; then
    command -v direnv >/dev/null && cat > .envrc <<'EOF'
source .venv/bin/activate
PATH_add "$HOME/.cargo/bin"
EOF
    command -v direnv >/dev/null && direnv allow
  fi
}
# venvの適用
va() {
  local venv=${1:-.venv}
  [[ -f "$venv/bin/activate" ]] || { echo "no such venv: $venv" >&2; return 1; }
  source "$venv/bin/activate"
}

# direnvでsourceした際、環境変数の変更のせいかdeactivateが使用できないため
function vadeactivate () {
        if [ -n "${_OLD_VIRTUAL_PATH:-}" ]
        then
                PATH="${_OLD_VIRTUAL_PATH:-}"
                export PATH
                unset _OLD_VIRTUAL_PATH
        fi
        if [ -n "${_OLD_VIRTUAL_PYTHONHOME:-}" ]
        then
                PYTHONHOME="${_OLD_VIRTUAL_PYTHONHOME:-}"
                export PYTHONHOME
                unset _OLD_VIRTUAL_PYTHONHOME
        fi
        if [ -n "${BASH:-}" -o -n "${ZSH_VERSION:-}" ]
        then
                hash -r 2> /dev/null
        fi
        if [ -n "${_OLD_VIRTUAL_PS1:-}" ]
        then
                PS1="${_OLD_VIRTUAL_PS1:-}"
                export PS1
                unset _OLD_VIRTUAL_PS1
        fi
        unset VIRTUAL_ENV
        unset VIRTUAL_ENV_PROMPT
        if [ ! "${1:-}" = "nondestructive" ]
        then
                unset -f vadeactivate
        fi
}
