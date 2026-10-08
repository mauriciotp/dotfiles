#!/usr/bin/env bash
# Liga as configurações deste repositório nos lugares esperados.
#
# Idempotente: pode rodar de novo a qualquer momento. Um arquivo que já existe e não é
# o link certo vai para ~/.dotfiles-backup/<data>/ antes de ser substituído.
#
# Uso: ~/dotfiles/install.sh [pessoal|empresa] [--dry-run]
#
# O perfil fica salvo em ~/.config/dotfiles/perfil; nas próximas vezes não precisa repetir.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$HOME/.config/dotfiles"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0
PERFIL=""
for arg in "$@"; do
  case "$arg" in
  --dry-run) DRY_RUN=1 ;;
  pessoal | empresa) PERFIL="$arg" ;;
  -h | --help)
    sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'
    exit 0
    ;;
  *)
    echo "argumento desconhecido: $arg (use pessoal, empresa ou --dry-run)" >&2
    exit 1
    ;;
  esac
done

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

# Conta local (no /etc/passwd) pode trocar o login shell com chsh. Conta de domínio/LDAP
# (comum no computador da empresa) não pode: o login continua no bash, que troca para o
# zsh no ~/.bashrc. Só acrescenta se ainda não houver.
ensure_zsh_shell() {
  local login_shell
  login_shell="$(getent passwd "$USER" | cut -d: -f7)"
  case "$login_shell" in
  */zsh)
    echo "ok       login shell já é zsh"
    return
    ;;
  esac
  if grep -q "^$USER:" /etc/passwd; then
    echo "AÇÃO     login shell é ${login_shell:-?}; rode: chsh -s \"\$(command -v zsh)\""
    return
  fi
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

# No perfil empresa o e-mail do git fica no ~/.gitconfig.local, fora do repositório público
ensure_git_email() {
  local email
  email="$(git config --file ~/.gitconfig.local user.email 2>/dev/null || true)"
  if [ -n "$email" ]; then
    echo "ok       e-mail do git: $email (~/.gitconfig.local)"
    return
  fi
  if [ "$DRY_RUN" = 1 ]; then
    echo "  [dry-run] perguntaria o e-mail do git e gravaria em ~/.gitconfig.local"
    return
  fi
  if [ ! -t 0 ]; then
    echo "AÇÃO     defina o e-mail: git config --file ~/.gitconfig.local user.email voce@empresa.com"
    return
  fi
  read -rp "E-mail do git neste computador (fica em ~/.gitconfig.local): " email
  if [ -n "$email" ]; then
    git config --file ~/.gitconfig.local user.email "$email"
    echo "gravado  ~/.gitconfig.local"
  else
    echo "AÇÃO     sem e-mail o git recusa commits: git config --file ~/.gitconfig.local user.email ..."
  fi
}

# Perfil: argumento > o salvo da última instalação > pergunta (sugerindo pelo tipo de conta)
choose_profile() {
  if [ -z "$PERFIL" ] && [ -f "$STATE/perfil" ]; then
    PERFIL="$(cat "$STATE/perfil")"
  fi
  if [ -z "$PERFIL" ]; then
    local sugestao=pessoal
    grep -q "^$USER:" /etc/passwd || sugestao=empresa
    if [ ! -t 0 ]; then
      echo "informe o perfil: $0 pessoal|empresa" >&2
      exit 1
    fi
    read -rp "Perfil desta máquina (pessoal/empresa) [$sugestao]: " PERFIL
    PERFIL="${PERFIL:-$sugestao}"
  fi
  case "$PERFIL" in
  pessoal | empresa) ;;
  *)
    echo "perfil inválido: $PERFIL" >&2
    exit 1
    ;;
  esac
  echo "perfil   $PERFIL"
  if [ "$(cat "$STATE/perfil" 2>/dev/null)" != "$PERFIL" ]; then
    run mkdir -p "$STATE"
    [ "$DRY_RUN" = 1 ] || echo "$PERFIL" >"$STATE/perfil"
  fi
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

echo "== perfil"
choose_profile

echo "== links"
link nvim ~/.config/nvim
link tmux/tmux.conf ~/.tmux.conf
link tmux/tmux-claude-focus ~/.local/bin/tmux-claude-focus
link zsh/zshrc ~/.zshrc
link zsh/zshenv ~/.zshenv
link ghostty/config.ghostty ~/.config/ghostty/config.ghostty
link starship/starship.toml ~/.config/starship.toml
link git/gitconfig ~/.gitconfig
link "git/$PERFIL.gitconfig" "$STATE/gitconfig"
link "zsh/perfil/$PERFIL.zsh" "$STATE/perfil.zsh"
# um link por arquivo: ~/.claude/commands pode ter comandos que não são deste repo
for f in "$DOTFILES"/claude/commands/*.md; do
  link "claude/commands/$(basename "$f")" ~/.claude/commands/"$(basename "$f")"
done

echo "== cópias"
# o Claude Code reescreve o settings.json pelo /config; um link seria trocado por arquivo
copy_once claude/settings.json ~/.claude/settings.json

echo "== shell"
ensure_zsh_shell

if [ "$PERFIL" = empresa ]; then
  echo "== git"
  ensure_git_email
fi

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
