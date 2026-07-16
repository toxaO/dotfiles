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
# prompt machine color check
#--------------------------------------------------
prompt_machine_color_check() {
  local -a machines=(macbook win wsl cloud kvm hermes other)
  local machine colors fg bg

  for machine in "${machines[@]}"; do
    colors=(${=$(prompt-machine-colors "$machine")})
    fg="${colors[1]}"
    bg="${colors[2]}"
    printf '%-8s ' "$machine"
    print -P "%K{${bg}}%F{${fg}}  SAMPLE  %f%k fg=${fg} bg=${bg}"
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
unalias cr 2>/dev/null

_agents_dotfiles_dir() {
  local dir="$HOME/dotfiles"

  if [ ! -d "$dir" ]; then
    echo "dotfiles directory not found: $dir" >&2
    return 1
  fi

  print -r -- "${dir:A}"
}

_agents_project_name() {
  local dir="${1:-$PWD}"
  local top

  top="$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)" || top="$dir"
  top="${top:A}"
  if [[ "$top" == "$HOME/"* ]]; then
    top="${top#$HOME/}"
  fi
  top="${top// /_}"
  top="${top//\//__}"
  print -r -- "$top"
}

_agents_base_path() {
  local dotfiles_dir

  dotfiles_dir="$(_agents_dotfiles_dir)" || return 1
  print -r -- "$dotfiles_dir/agents/base.md"
}

_agents_project_path() {
  local dir="${1:-$PWD}"
  local dotfiles_dir project_name

  dotfiles_dir="$(_agents_dotfiles_dir)" || return 1
  project_name="$(_agents_project_name "$dir")" || return 1
  print -r -- "$dotfiles_dir/agents/projects/$project_name/AGENTS.md"
}

_agents_write_main() {
  local dest="$1"
  local base="$2"
  local project="$3"

  {
    print -r -- "# AGENTS.md"
    print -r -- ""
    print -r -- "@$base"
    print -r -- "@$project"
  } > "$dest"
}

_agents_write_claude() {
  local dest="$1"
  local base="$2"
  local project="$3"
  local service="$4"

  {
    print -r -- "# CLAUDE.md"
    print -r -- ""
    print -r -- "@$base"
    print -r -- "@$project"
    print -r -- "@$service"
  } > "$dest"
}

_agents_ensure_project() {
  local dir="$1"
  local project="$2"
  local dotfiles_dir project_template legacy

  dotfiles_dir="$(_agents_dotfiles_dir)" || return 1
  project_template="$dotfiles_dir/templates/AGENTS_PROJECT.md"
  legacy="$dir/AGENTS_PROJECT.md"

  if [ -e "$project" ]; then
    if [ -e "$legacy" ]; then
      rm -f "$legacy" || return 1
    fi
    return 0
  fi

  if [ ! -f "$project_template" ]; then
    echo "project template not found: $project_template" >&2
    return 1
  fi

  mkdir -p "${project:h}" || return 1

  if [ -f "$legacy" ]; then
    mv "$legacy" "$project" || return 1
    return 0
  fi

  cp "$project_template" "$project" || return 1
}

_agents_ensure_repo_docs() {
  local dir="${1:-$PWD}"
  local main="$dir/AGENTS.md"
  local claude="$dir/CLAUDE.md"
  local project base service

  project="$(_agents_project_path "$dir")" || return 1
  base="$(_agents_base_path)" || return 1
  service="$(_agents_dotfiles_dir)/agents/services/claude-code.md"
  if [ ! -f "$service" ]; then
    echo "service template not found: $service" >&2
    return 1
  fi

  _agents_ensure_project "$dir" "$project" || return 1

  if [ ! -e "$main" ]; then
    _agents_write_main "$main" "$base" "$project" || return 1
  fi

  if [ ! -e "$claude" ]; then
    _agents_write_claude "$claude" "$base" "$project" "$service" || return 1
  fi
}

agents_template() {
  local dest_dir main project base
  dest_dir="${1:-$PWD}"

  if [[ "$dest_dir" == */AGENTS.md ]]; then
    dest_dir="${dest_dir:h}"
  fi

  main="$dest_dir/AGENTS.md"
  project="$(_agents_project_path "$dest_dir")" || return 1
  base="$(_agents_base_path)" || return 1

  if [ -e "$main" ]; then
    echo "already exists: $main" >&2
    return 1
  fi

  _agents_ensure_project "$dest_dir" "$project" || return 1
  _agents_write_main "$main" "$base" "$project" || return 1
  echo "created: $main"
  echo "project: $project"
}

agents_migrate() {
  local dest_dir main project base
  dest_dir="${1:-$PWD}"

  if [[ "$dest_dir" == */AGENTS.md ]]; then
    dest_dir="${dest_dir:h}"
  fi

  main="$dest_dir/AGENTS.md"
  project="$(_agents_project_path "$dest_dir")" || return 1
  base="$(_agents_base_path)" || return 1

  if [ ! -f "$main" ]; then
    echo "not found: $main" >&2
    return 1
  fi

  _agents_ensure_project "$dest_dir" "$project" || return 1
  _agents_write_main "$main" "$base" "$project" || return 1
  echo "migrated: $main"
  echo "project: $project"
}

agents_refresh() {
  local dest_dir main project base
  dest_dir="${1:-$PWD}"

  if [[ "$dest_dir" == */AGENTS.md ]]; then
    dest_dir="${dest_dir:h}"
  fi

  main="$dest_dir/AGENTS.md"
  project="$(_agents_project_path "$dest_dir")" || return 1
  base="$(_agents_base_path)" || return 1

  if [ ! -f "$project" ]; then
    echo "not found: $project" >&2
    return 1
  fi

  _agents_write_main "$main" "$base" "$project" || return 1
  echo "refreshed: $main"
}

function cx {
  local project
  local agent_editor="${AGENTS_EDITOR:-nvim}"
  project="$(_agents_project_path "$PWD")" || return 1

  if [ ! -f "$PWD/AGENTS.md" ] || [ ! -f "$PWD/CLAUDE.md" ]; then
    _agents_ensure_repo_docs "$PWD" || return 1
    "$agent_editor" "$project" || return 1
  fi

  codex "$@"
}

cr() {
  _agents_ensure_repo_docs "$PWD" || return 1
  codex resume "$@"
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

# Obsidian vault で Hermes を起動する。
# vault へ cd してから hermes を起動することで、vault ルートの AGENTS.md
# (→ AGENTS_PROJECT.md の Startup Protocol)が cwd 経由で自動注入され、
# Hermes が起動時に 07_hermes/current.md を読む運用になる。
hermes_obsidian() {
  local vault="${HERMES_OBSIDIAN_VAULT:-$HOME/workspace/obsidian}"

  if ! command -v hermes >/dev/null; then
    echo "hermes not found" >&2
    return 1
  fi
  if [ ! -d "$vault" ]; then
    echo "obsidian vault not found: $vault" >&2
    return 1
  fi
  if [ ! -f "$vault/AGENTS.md" ]; then
    echo "warning: $vault/AGENTS.md not found (Startup Protocol は自動注入されない)" >&2
  fi

  ( cd "$vault" && hermes "$@" )
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
