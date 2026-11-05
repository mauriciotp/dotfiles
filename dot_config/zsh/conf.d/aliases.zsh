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
