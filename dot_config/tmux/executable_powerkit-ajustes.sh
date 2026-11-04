#!/usr/bin/env bash
# Ajustes no visual do PowerKit 7.7.0 com fundo transparente + espaçamento.
# Chamado pelo ~/.tmux.conf depois do TPM (o PowerKit monta tudo ao carregar).
#
# Bug: cada aba começa com "" (meia-lua que FECHA um segmento) pintada na cor
# do fundo da barra, um encaixe pensado para segmentos colados. Com fundo
# transparente e espaço entre os elementos, aparece um meio-círculo escuro
# no início da aba. O certo é "" (meia-lua que ABRE) na cor da própria aba,
# sobre o fundo do terminal.
set -euo pipefail

abre=$''
fecha=$''

for opcao in window-status-format window-status-current-format; do
    formato=$(tmux show -gv "$opcao")
    # início da aba: #[range=window|#{window_id}]#[fg=<fundo>(#),bg=<cor da aba>]
    padrao="^(#\[range=window\|#\{window_id\}\])#\[fg=#[0-9a-fA-F]{6}#?,bg=(#[0-9a-fA-F]{6})\]${fecha}"
    if [[ $formato =~ $padrao ]]; then
        inicio="${BASH_REMATCH[1]}#[fg=${BASH_REMATCH[2]},bg=default]${abre}"
        tmux set -g "$opcao" "${inicio}${formato:${#BASH_REMATCH[0]}}"
    fi
done
