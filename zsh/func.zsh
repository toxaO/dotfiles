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

  local base_dir picked_dir
  base_dir="$HOME"

  if command -v fzf >/dev/null; then
    if command -v fd >/dev/null; then
      picked_dir="$(fd -t d -H --exclude .git --exclude node_modules --exclude .cache --max-depth 3 . "$base_dir" | \
        fzf --prompt="Dir> " --height=40% \
        --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
        --bind="ctrl-d:reload(fd -t d -H --exclude .git --exclude node_modules --exclude .cache . \"$base_dir\")" \
        --bind="ctrl-s:reload(fd -t d -H --exclude .git --exclude node_modules --exclude .cache --max-depth 3 . \"$base_dir\")")"
    else
      picked_dir="$(find "$base_dir" -maxdepth 3 -type d 2>/dev/null | \
        fzf --prompt="Dir> " --height=40% \
        --header="Ctrl-d: deep search / Ctrl-s: shallow search" \
        --bind="ctrl-d:reload(find \"$base_dir\" -type d 2>/dev/null)" \
        --bind="ctrl-s:reload(find \"$base_dir\" -maxdepth 3 -type d 2>/dev/null)")"
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

unalias cx 2>/dev/null

_agents_dotfiles_dir() {
  local dir="${DOTFILES_DIR:-$HOME/dotfiles}"

  if [ ! -d "$dir" ]; then
    echo "dotfiles directory not found: $dir" >&2
    echo "Set DOTFILES_DIR to the dotfiles path." >&2
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
