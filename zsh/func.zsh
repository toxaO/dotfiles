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


