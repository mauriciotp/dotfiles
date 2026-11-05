# Prompt, zoxide, fzf, mise e bat
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

# fzf: fd respeita o .gitignore (o buscador embutido do fzf não).
# As variáveis vêm antes do "fzf --zsh": depois não têm efeito (README do fzf).
export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat -n --color=always {}' --bind 'ctrl-/:change-preview-window(down|hidden|)'"
export FZF_ALT_C_COMMAND='fd --type d --hidden --exclude .git'
export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons=always --color=always {}'"
# cores do Noctalia: o template acrescenta ao FZF_DEFAULT_OPTS
[[ -r ${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/noctalia.sh ]] && source "${XDG_CONFIG_HOME:-$HOME/.config}/fzf/themes/noctalia.sh"
source <(fzf --zsh)   # Ctrl+R histórico, Ctrl+T arquivos, Alt+C pastas

command -v mise >/dev/null && eval "$(mise activate zsh)"

# man colorido pelo bat (README do bat); o tema está em ~/.config/bat/config
export MANPAGER='bat -plman'
