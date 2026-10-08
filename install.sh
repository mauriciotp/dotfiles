#!/usr/bin/env bash
# Liga as configurações deste repositório nos lugares esperados.
#
# Idempotente: pode rodar de novo a qualquer momento. Um arquivo que já existe e não é
# o link certo vai para ~/.dotfiles-backup/<data>/ antes de ser substituído.
#
# Uso: ~/dotfiles/install.sh [--dry-run]

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
[ "${1:-}" = "--dry-run" ] && DRY_RUN=1

run() {
  if [ "$DRY_RUN" = 1 ]; then echo "  [dry-run] $*"; else "$@"; fi
}

# link <origem no repo> <destino>
link() {
  local src="$DOTFILES/$1" dst="$2"
  if [ "$(readlink "$dst" 2>/dev/null)" = "$src" ]; then
    echo "ok       $dst"
    return
  fi
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "backup   $dst -> $BACKUP/"
    run mkdir -p "$BACKUP"
    run mv "$dst" "$BACKUP/"
  fi
  echo "link     $dst -> $src"
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
}

# copy <origem no repo> <destino>: só se o destino não existir (o app reescreve o arquivo)
copy_once() {
  local src="$DOTFILES/$1" dst="$2"
  if [ -e "$dst" ]; then
    echo "mantido  $dst (já existe; compare com $src)"
    return
  fi
  echo "copia    $dst"
  run mkdir -p "$(dirname "$dst")"
  run cp "$src" "$dst"
}

# Contas de domínio/LDAP não aparecem no /etc/passwd e não podem usar chsh: o login
# continua no bash, que troca para o zsh no ~/.bashrc. Só acrescenta se ainda não houver.
ensure_bash_execs_zsh() {
  local login_shell
  login_shell="$(getent passwd "$USER" | cut -d: -f7)"
  case "$login_shell" in
  */zsh)
    echo "ok       login shell já é zsh"
    return
    ;;
  esac
  if grep -qE 'exec .*zsh|^# dotfiles: o login shell' ~/.bashrc 2>/dev/null; then
    echo "ok       ~/.bashrc já troca para o zsh"
    return
  fi
  echo "bashrc   ~/.bashrc passa a trocar para o zsh (login shell: ${login_shell:-?})"
  [ "$DRY_RUN" = 1 ] && return
  cat >>~/.bashrc <<'BASH'

# dotfiles: o login shell não pode ser trocado (chsh); abre o zsh a partir do bash interativo
if command -v zsh >/dev/null; then
  export SHELL="$(command -v zsh)"
  exec "$SHELL"
fi
BASH
}

# clone <repo> <destino>
clone() {
  if [ -d "$2" ]; then
    echo "ok       $2"
    return
  fi
  echo "clone    $1 -> $2"
  run git clone --depth 1 "$1" "$2"
}

echo "== links"
link nvim ~/.config/nvim
link tmux/tmux.conf ~/.tmux.conf
link tmux/tmux-claude-focus ~/.local/bin/tmux-claude-focus
link zsh/zshrc ~/.zshrc
link zsh/zshenv ~/.zshenv
link ghostty/config.ghostty ~/.config/ghostty/config.ghostty
link starship/starship.toml ~/.config/starship.toml
link git/gitconfig ~/.gitconfig
# um link por arquivo: ~/.claude/commands pode ter comandos que não são deste repo
for f in "$DOTFILES"/claude/commands/*.md; do
  link "claude/commands/$(basename "$f")" ~/.claude/commands/"$(basename "$f")"
done

echo "== cópias"
# o Claude Code reescreve o settings.json pelo /config; um link seria trocado por arquivo
copy_once claude/settings.json ~/.claude/settings.json

echo "== shell"
ensure_bash_execs_zsh

echo "== gerenciadores de plugins"
clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
clone https://github.com/zap-zsh/zap "${XDG_DATA_HOME:-$HOME/.local/share}/zap"

echo
echo "Pronto. Próximos passos:"
echo "  - tmux: abra o tmux e aperte prefix + I (C-a I) para instalar os plugins"
echo "  - nvim: abra o nvim; o lazy.nvim instala os plugins sozinho"
echo "  - zsh:  abra um terminal novo (o zap baixa os plugins na primeira vez)"
[ -d "$BACKUP" ] && echo "  - arquivos substituídos estão em $BACKUP"
exit 0
