# Aliases
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first'
alias la='eza -la --icons=auto --git --group-directories-first'
alias tree='eza --tree --icons=auto'
alias cat='bat --paging=never'
alias v='nvim'

# y: abre o yazi e, ao sair com q, o shell fica na pasta onde o yazi estava
# (Q sai sem mudar). Função do Quick Start do yazi.
function y() {
	local tmp cwd
	tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

# tdl: layout de trabalho no tmux (função tdl do Omarchy). Neovim à esquerda,
# a IA à direita (30%), um terminal embaixo (15%).
# Uso: tdl [comando da IA, padrão claude] [segunda IA, embaixo da primeira]
function tdl() {
	[[ -z $TMUX ]] && { echo "tdl: run it inside tmux." >&2; return 1; }
	local ai="${1:-claude}" ai2="$2" dir="$PWD" editor="$TMUX_PANE" ai_pane ai2_pane
	tmux rename-window -t "$editor" "${dir:t}"
	tmux split-window -v -l 15% -t "$editor" -c "$dir"
	ai_pane=$(tmux split-window -h -l 30% -t "$editor" -c "$dir" -P -F '#{pane_id}')
	if [[ -n $ai2 ]]; then
		ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$dir" -P -F '#{pane_id}')
		tmux send-keys -t "$ai2_pane" "$ai2" C-m
	fi
	tmux send-keys -t "$ai_pane" "$ai" C-m
	tmux send-keys -t "$editor" "${EDITOR:-nvim} ." C-m
	# o Omarchy seleciona "$opencode_pane", que não existe nessa função; aqui é o editor
	tmux select-pane -t "$editor"
}
