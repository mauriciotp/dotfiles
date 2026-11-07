# Completação, com o fzf-tab: o Tab abre as opções no fzf (busca difusa + prévia)
zcompdump="${XDG_CACHE_HOME:-$HOME/.cache}/zsh/zcompdump"
[[ -d ${zcompdump:h} ]] || mkdir -p "${zcompdump:h}"
autoload -Uz compinit && compinit -d "$zcompdump"
unset zcompdump

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'   # ignora maiúsculas/minúsculas
eval "$(dircolors -b)"                                     # define LS_COLORS (cores por tipo de arquivo)
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*:descriptions' format '[%d]'         # nomeia os grupos (o fzf-tab usa)
zstyle ':completion:*:git-checkout:*' sort false          # branches na ordem do git
zstyle ':completion:*' menu no                            # o menu é o fzf-tab

# depois do compinit e antes dos plugins que embrulham widgets (plugins.zsh)
source /usr/share/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
# O "fzf --zsh" (tools.zsh) assume o Tab para o **<Tab> e devolve ao fzf-tab no resto.
zstyle ':fzf-tab:*' use-fzf-default-opts yes              # cores do Noctalia (tools.zsh)
zstyle ':fzf-tab:*' switch-group '<' '>'                  # < e > trocam de grupo
zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' fzf-preview 'eza -1 --color=always --icons=always $realpath'
# dentro do tmux, abre num popup flutuante em vez de ocupar o pane
[[ -n $TMUX ]] && zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
# Tamanho do popup: o ftb-tmux-popup mede só o nome mais longo e não conta a
# prévia (lib/ftb-tmux-popup do fzf-tab), então a prévia saía cortada.
# popup-min-size: mínimo de colunas e linhas; popup-pad: colunas a mais onde há prévia.
zstyle ':fzf-tab:*' popup-min-size 80 12
zstyle ':fzf-tab:complete:(cd|z|__zoxide_z):*' popup-pad 50 0
