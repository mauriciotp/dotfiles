#!/bin/sh
# Aplicativos padrão do xdg-open. Grava no ~/.config/mimeapps.list, que outros
# apps também editam (por isso o arquivo não fica no chezmoi): só as linhas
# daqui são trocadas. Roda de novo quando esta lista muda.
command -v xdg-mime >/dev/null 2>&1 || exit 0
xdg-mime default yazi-ghostty.desktop inode/directory # pastas: yazi no Ghostty
exit 0
