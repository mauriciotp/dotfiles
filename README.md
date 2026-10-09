# dotfiles

Minhas configurações de terminal e editor: Neovim (LazyVim), tmux, zsh, Ghostty, starship, git
e Claude Code, integrado ao Neovim e ao tmux. Um `install.sh` liga tudo nos lugares certos, então a mesma
configuração sobe em qualquer máquina, com dois perfis: **pessoal** e **empresa**
(veja [Perfis](#perfis)).

| Pasta       | Vai para                                   | O que tem                                                   |
| ----------- | ------------------------------------------ | ----------------------------------------------------------- |
| `nvim/`     | `~/.config/nvim`                           | LazyVim + Claude Code no tmux ([README](nvim/README.md))    |
| `tmux/`     | `~/.tmux.conf`, `~/.local/bin/`            | prefix `C-a`, tpm, resurrect/continuum, atalhos do Claude   |
| `zsh/`      | `~/.zshrc`, `~/.zshenv`                    | zap (autosuggestions, z, syntax highlighting), fzf, nvm     |
| `ghostty/`  | `~/.config/ghostty/config.ghostty`         | JetBrains Mono Nerd Font, Catppuccin Mocha                  |
| `starship/` | `~/.config/starship.toml`                  | símbolos Nerd Font do prompt                                |
| `git/`      | `~/.gitconfig`                             | nome e assinatura de commits com chave SSH; e-mail por perfil |
| `claude/`   | `~/.claude/settings.json`                  | preferências do Claude Code (os prompts ficam no [nvim](nvim/README.md)) |

O tema é Catppuccin Mocha em todo lugar (Ghostty, tmux-powerkit, Neovim).

## Perfis

Quase tudo é igual nas duas máquinas. Neovim, tmux, Ghostty, starship, Claude Code e o grosso do
zsh são os mesmos. O que muda:

|                       | Pessoal                                    | Empresa                                                  |
| --------------------- | ------------------------------------------ | -------------------------------------------------------- |
| E-mail do git         | `mauricio.tp_@outlook.com`, no repositório (`git/pessoal.gitconfig`) | perguntado na instalação e gravado em `~/.gitconfig.local`, **nunca** no repositório (ele é público) |
| Commit sem e-mail     | —                                          | recusado (`user.useConfigOnly`), em vez de sair com e-mail errado |
| Trecho extra do zsh   | `zsh/perfil/pessoal.zsh` (vazio por enquanto) | `zsh/perfil/empresa.zsh` (vazio por enquanto)            |
| Login shell           | conta local: `chsh` para zsh               | conta de domínio/LDAP costuma não aceitar `chsh`: o `~/.bashrc` abre o zsh |
| Segredos              | `~/.zshrc.local`                           | `~/.zshrc.local` (tokens, URLs internas, proxy)          |

Como o perfil é aplicado:

- `./install.sh pessoal` ou `./install.sh empresa` grava a escolha em `~/.config/dotfiles/perfil`.
  Nas próximas vezes, `./install.sh` sem argumento usa a mesma. Sem argumento e sem escolha
  salva, ele pergunta, sugerindo **empresa** quando a conta não está no `/etc/passwd`
  (conta de domínio).
- Em `~/.config/dotfiles/` ficam dois links para os arquivos do perfil: `gitconfig` (incluído pelo
  `~/.gitconfig`) e `perfil.zsh` (carregado pelo `~/.zshrc`).
- A ordem é sempre comum → perfil → local: `~/.gitconfig.local` e `~/.zshrc.local` vêm por último
  e vencem os anteriores. Use os dois para o que é só daquela máquina.

O login shell não depende do perfil, e sim do tipo de conta, que o `install.sh` detecta.
Numa conta local, ele só avisa para rodar `chsh`. Numa conta de domínio, ele acrescenta ao
`~/.bashrc` o bloco que troca para o zsh.

Por que não `chsh` na conta de domínio: a conta vem do AD/LDAP via `sssd` (`getent passwd`
mostra o usuário, mas o `/etc/passwd` não), e o `chsh` só edita o `/etc/passwd`. Ele pede a senha
e então falha com `user '...' does not exist in /etc/passwd`. Com `sudo`, o `sssd` aceita
sobrescrever o shell localmente (`sudo sss_override user-add "$USER" -s /usr/bin/zsh` e reiniciar
o `sssd`), mas isso mexe na configuração do sistema da empresa. O `~/.bashrc` resolve sem
privilégio nenhum.

Para trocar o perfil de uma máquina: `./install.sh pessoal` (ou `empresa`) de novo.

## Máquina nova

### 1. Dependências

Exemplo para Ubuntu/Debian; em outras distros os nomes dos pacotes mudam pouco.

```sh
sudo apt install zsh git curl unzip build-essential ripgrep fd-find bat iproute2
```

No Ubuntu, `bat` e `fd` vêm como `batcat` e `fdfind`; o zshrc e o LazyVim já lidam com isso.

No computador da empresa, se não houver `sudo`, peça os pacotes do apt (e o tmux, o Ghostty e a
fonte) ao suporte. Da tabela abaixo, dá para instalar sem `sudo`, no seu home:

- fzf, nvm e Claude Code: os instaladores já usam o home;
- Neovim: extraia o tarball em `~/.local` em vez de `/opt`;
- starship: `curl -sS https://starship.rs/install.sh | sh -s -- -b ~/.local/bin`.

O resto vem dos instaladores oficiais, porque o apt costuma ter versões velhas:

| Ferramenta                 | Como instalar                                                                  |
| -------------------------- | ------------------------------------------------------------------------------ |
| Neovim ≥ 0.11              | tarball de [releases](https://github.com/neovim/neovim/releases) em `/opt` ou `/usr/local` |
| tmux ≥ 3.3                 | apt (se for ≥ 3.3) ou [código-fonte](https://github.com/tmux/tmux/releases); o `tmux.conf` usa `allow-passthrough` e `extended-keys` |
| Ghostty ≥ 1.2              | [ghostty.org/download](https://ghostty.org/download) (aqui: snap); versões antigas leem `config` em vez de `config.ghostty` |
| JetBrains Mono Nerd Font   | [nerdfonts.com](https://www.nerdfonts.com/font-downloads) → `~/.local/share/fonts`, depois `fc-cache -f` |
| starship                   | `curl -sS https://starship.rs/install.sh \| sh`                                 |
| fzf ≥ 0.48                 | `git clone --depth 1 https://github.com/junegunn/fzf ~/.fzf && ~/.fzf/install --bin` (o apt costuma ser antigo demais para `fzf --zsh`) |
| eza (ou exa)               | [eza](https://github.com/eza-community/eza/blob/main/INSTALL.md); o zshrc usa o que achar |
| nvm + Node                 | [nvm](https://github.com/nvm-sh/nvm#installing-and-updating), depois `nvm install --lts` |
| Claude Code                | `curl -fsSL https://claude.ai/install.sh \| bash`                               |
| lazygit, gh                | opcionais: [lazygit](https://github.com/jesseduffield/lazygit#installation), [gh](https://cli.github.com) |

Go, bun, cargo, foundry etc. são opcionais: o zshrc só coloca no `PATH` o que existir.

### 2. Clonar e instalar

```sh
# por HTTPS: numa máquina nova ainda não há chave SSH cadastrada no GitHub
git clone https://github.com/mauriciotp/dotfiles.git ~/dotfiles

# computador pessoal
~/dotfiles/install.sh pessoal --dry-run   # mostra o que vai fazer
~/dotfiles/install.sh pessoal

# computador da empresa (pergunta o e-mail do git)
~/dotfiles/install.sh empresa --dry-run
~/dotfiles/install.sh empresa
```

Para dar push dessa máquina depois, cadastre uma chave SSH e troque o remote:
`git -C ~/dotfiles remote set-url origin git@github.com:mauriciotp/dotfiles.git`.

O `install.sh`:

- aplica o perfil (veja [Perfis](#perfis)) e, no da empresa, pergunta o e-mail do git se o
  `~/.gitconfig.local` ainda não tiver um;
- cria os links da tabela acima. Um arquivo que já existia vai para
  `~/.dotfiles-backup/<data>/` (no mesmo caminho relativo ao home), nada é apagado;
- copia o `claude/settings.json` só se ainda não existir: o Claude Code reescreve esse arquivo
  pelo `/config`, e um link viraria arquivo comum. Para levar uma mudança dele ao repositório,
  copie de volta à mão;
- cuida do login shell: avisa para rodar `chsh` numa conta local, ou faz o `~/.bashrc` abrir o
  zsh numa conta de domínio;
- clona o [tpm](https://github.com/tmux-plugins/tpm) e o [zap](https://github.com/zap-zsh/zap).

Pode rodar de novo sempre que quiser: o que já está certo aparece como `ok`, e linhas `AÇÃO`
indicam algo que você precisa fazer à mão.

### 3. Primeira abertura

- **zsh**: abra um terminal novo; o zap baixa os plugins.
- **tmux**: abra o tmux e aperte `C-a I` para o tpm instalar os plugins. Depois de editar o
  `tmux.conf`, `C-a r` recarrega.
- **Neovim**: abra o `nvim`; o lazy.nvim instala os plugins nas versões do `lazy-lock.json`.
- **git**: a assinatura de commits espera a chave `~/.ssh/id_ed25519_sign.pub`. Copie a chave
  da máquina antiga ou gere uma nova (`ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_sign`) e
  cadastre em *GitHub → Settings → SSH and GPG keys* como **Signing key**. Sem a chave, todo
  `git commit` falha (o `gitconfig` assina sempre).
  - **Empresa**: se a empresa usa outro GitHub/GitLab, gere uma chave só para ela, cadastre lá e
    aponte no `~/.gitconfig.local`: `git config --file ~/.gitconfig.local user.signingkey ~/.ssh/<chave>.pub`.
    Se os commits de lá não devem ser assinados: `git config --file ~/.gitconfig.local commit.gpgsign false`.
  - Confira com `git config --show-origin user.email` de onde vem o e-mail.
- **Claude Code**: `claude` e faça login.

## Fora do repositório (de propósito)

- **Segredos e coisas de uma máquina só**: `~/.zshrc.local` e `~/.gitconfig.local`, carregados por
  último se existirem. Tokens, e-mail e URLs da empresa, aliases para caminhos locais.
- **Chaves SSH, login do gh (`~/.config/gh/hosts.yml`), credenciais do Claude**: cada máquina tem as
  suas.
- **`~/.claude/keybindings.json`**: o arquivo atual é a lista padrão inteira do Claude Code. Commitar
  travaria os atalhos padrão da versão de hoje; só vale guardar se você customizar algo.
- **`~/.ssh/config`**: tem os hosts das máquinas que você acessa; fica fora de um repositório público.
- **VS Code**: usa o Settings Sync da própria conta, que já leva configurações e extensões.

## Como manter

A regra é: **toda mudança de configuração passa por este repositório**.

- Os arquivos são links, então editar `~/.zshrc`, `~/.tmux.conf` etc. já edita o repositório.
  Depois é `cd ~/dotfiles && git add -p && git commit`.
- Para guardar uma configuração nova: mova o arquivo para uma pasta aqui, acrescente uma linha
  `link` no `install.sh`, rode `./install.sh` e adicione a linha na tabela do topo.
- Antes de commitar, pergunte **onde a mudança deve morar**:
  - vale nas duas máquinas → arquivo comum (`zsh/zshrc`, `git/gitconfig`…);
  - vale num perfil só → `zsh/perfil/<perfil>.zsh` ou `git/<perfil>.gitconfig`;
  - é segredo, ou é da empresa e não pode ser público → `~/.zshrc.local` / `~/.gitconfig.local`, fora do git.
- Se a mudança exige um passo manual (instalar algo, gerar uma chave), escreva o passo em
  "Máquina nova" no mesmo commit. É isso que garante que a próxima instalação funcione.
- O `git log` é o histórico das mudanças; mensagens de commit descritivas valem como diário.
