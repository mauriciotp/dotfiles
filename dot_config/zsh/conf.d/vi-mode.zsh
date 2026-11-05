# Edição da linha no modo vi (Esc vai para o modo normal)
bindkey -v
KEYTIMEOUT=1   # o Esc vale em 10 ms (padrão: 0,4 s)

# No modo vi puro, Backspace, Ctrl+W e Ctrl+U não apagam o que estava antes do
# ponto onde a inserção começou. Aqui apagam, como no modo emacs.
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^U' backward-kill-line
# início e fim da linha no modo de inserção
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^E' end-of-line

# v no modo normal: edita o comando no $EDITOR (Neovim)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd v edit-command-line

# Cursor: barra no modo de inserção, bloco no normal (o Ghostty usa no-cursor
# para não brigar com isto). O Starship embrulha este widget para trocar a seta.
function _vi_cursor() {
	if [[ $KEYMAP == vicmd ]]; then
		print -n '\e[2 q'
	else
		print -n '\e[6 q'
	fi
}
zle -N zle-keymap-select _vi_cursor
zle -N zle-line-init _vi_cursor
# bloco de novo antes de rodar um comando (nvim, less etc. herdam o cursor)
autoload -Uz add-zsh-hook
function _vi_cursor_block() { print -n '\e[2 q' }
add-zsh-hook preexec _vi_cursor_block
