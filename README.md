# dotfiles

Minhas configurações de terminal e editor: Neovim (LazyVim + Claude Code), tmux, zsh, Ghostty,
starship, git e Claude Code. Um `install.sh` liga tudo nos lugares certos, então a mesma
configuração sobe em qualquer máquina.

| Pasta       | Vai para                                   | O que tem                                                   |
| ----------- | ------------------------------------------ | ----------------------------------------------------------- |
| `nvim/`     | `~/.config/nvim`                           | LazyVim + Claude Code no tmux ([README](nvim/README.md))    |
| `tmux/`     | `~/.tmux.conf`, `~/.local/bin/`            | prefix `C-a`, tpm, resurrect/continuum, atalhos do Claude   |
| `zsh/`      | `~/.zshrc`, `~/.zshenv`                    | zap (autosuggestions, z, syntax highlighting), fzf, nvm     |
| `ghostty/`  | `~/.config/ghostty/config.ghostty`         | JetBrains Mono Nerd Font, Catppuccin Mocha                  |
| `starship/` | `~/.config/starship.toml`                  | símbolos Nerd Font do prompt                                |
| `git/`      | `~/.gitconfig`                             | nome, e-mail e assinatura de commits com chave SSH          |
| `claude/`   | `~/.claude/commands/`, `~/.claude/settings.json` | slash commands `/testar`, `/corrigir`, `/explicar`; preferências |

O tema é Catppuccin Mocha em todo lugar (Ghostty, tmux-powerkit, Neovim).

## Máquina nova

### 1. Dependências

Exemplo para Ubuntu/Debian; em outras distros os nomes dos pacotes mudam pouco.

```sh
sudo apt install zsh git curl unzip build-essential ripgrep fd-find bat iproute2
chsh -s "$(command -v zsh)"
```

O resto vem dos instaladores oficiais, porque o apt costuma ter versões velhas:

| Ferramenta                 | Como instalar                                                                  |
| -------------------------- | ------------------------------------------------------------------------------ |
| Neovim ≥ 0.11              | tarball de [releases](https://github.com/neovim/neovim/releases) em `/opt` ou `/usr/local` |
| tmux ≥ 3.0                 | apt (se for ≥ 3.0) ou [código-fonte](https://github.com/tmux/tmux/releases)     |
| Ghostty                    | [ghostty.org/download](https://ghostty.org/download) (aqui: snap)               |
| JetBrains Mono Nerd Font   | [nerdfonts.com](https://www.nerdfonts.com/font-downloads) → `~/.local/share/fonts`, depois `fc-cache -f` |
| starship                   | `curl -sS https://starship.rs/install.sh \| sh`                                 |
| fzf                        | `git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --bin` |
| eza (ou exa)               | [eza](https://github.com/eza-community/eza/blob/main/INSTALL.md); o zshrc usa o que achar |
| nvm + Node                 | [nvm](https://github.com/nvm-sh/nvm#installing-and-updating), depois `nvm install --lts` |
| Claude Code                | `curl -fsSL https://claude.ai/install.sh \| bash`                               |
| lazygit, gh                | opcionais: [lazygit](https://github.com/jesseduffield/lazygit#installation), [gh](https://cli.github.com) |

Go, bun, cargo, foundry etc. são opcionais: o zshrc só coloca no `PATH` o que existir.

### 2. Clonar e instalar

```sh
git clone git@github.com:mauriciotp/dotfiles.git ~/dotfiles
~/dotfiles/install.sh --dry-run   # mostra o que vai fazer
~/dotfiles/install.sh
```

O `install.sh`:

- cria os links da tabela acima. Um arquivo que já existia vai para
  `~/.dotfiles-backup/<data>/`, nada é apagado;
- copia o `claude/settings.json` só se ainda não houver um (o Claude Code reescreve esse arquivo
  pelo `/config`, e um link seria trocado por arquivo comum);
- clona o [tpm](https://github.com/tmux-plugins/tpm) e o [zap](https://github.com/zap-zsh/zap).

Pode rodar de novo sempre que quiser: o que já está certo aparece como `ok`.

### 3. Primeira abertura

- **zsh**: abra um terminal novo; o zap baixa os plugins.
- **tmux**: abra o tmux e aperte `C-a I` para o tpm instalar os plugins.
- **Neovim**: abra o `nvim`; o lazy.nvim instala os plugins nas versões do `lazy-lock.json`.
- **git**: a assinatura de commits espera a chave `~/.ssh/id_ed25519_sign.pub`. Copie a chave
  da máquina antiga ou gere uma nova (`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_sign`) e
  cadastre em *GitHub → Settings → SSH and GPG keys* como **Signing key**.
- **Claude Code**: `claude` e faça login.

## Fora do repositório (de propósito)

- **Segredos e coisas desta máquina**: vão em `~/.zshrc.local`, que o zshrc carrega no fim se existir.
  Tokens, aliases para caminhos locais, variáveis de trabalho.
- **Chaves SSH, login do gh (`~/.config/gh/hosts.yml`), credenciais do Claude**: cada máquina tem as
  suas.
- **`~/.claude/keybindings.json`**: o arquivo atual é a lista padrão inteira do Claude Code. Commitar
  travaria os atalhos padrão da versão de hoje; só vale guardar se você customizar algo.

## Como manter

A regra é: **toda mudança de configuração passa por este repositório**.

- Os arquivos são links, então editar `~/.zshrc`, `~/.tmux.conf` etc. já edita o repositório.
  Depois é `cd ~/dotfiles && git add -p && git commit`.
- Para guardar uma configuração nova: mova o arquivo para uma pasta aqui, acrescente uma linha
  `link` no `install.sh`, rode `./install.sh` e adicione a linha na tabela do topo.
- Se a mudança exige um passo manual (instalar algo, gerar uma chave), escreva o passo em
  "Máquina nova" no mesmo commit. É isso que garante que a próxima instalação funcione.
- O `git log` é o histórico das mudanças; mensagens de commit descritivas valem como diário.
