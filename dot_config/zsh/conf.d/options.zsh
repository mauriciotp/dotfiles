# Opções gerais, PATH e editor
setopt AUTO_CD INTERACTIVE_COMMENTS

# Na sessão gráfica o uwsm já define isso (~/.config/uwsm/env); aqui cobre tty e ssh.
# typeset -U faz o array "path" (ligado ao PATH) ignorar entradas repetidas.
typeset -U path
path=("$HOME/.local/bin" "$HOME/go/bin" $path)
export EDITOR=nvim
export VISUAL=nvim
