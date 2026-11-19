# dotfiles

Configuração do meu Arch Linux com Hyprland, gerenciada pelo [chezmoi](https://www.chezmoi.io/).

Este README tem três partes:
1. **O que tem aqui**: o que cada pasta configura e como as peças se encaixam.
2. **Instalação**: o passo a passo numa máquina nova.
3. **Manutenção**: os comandos do dia a dia, o que cada um faz e as receitas para as situações comuns.

Se estiver perdido, vá direto para [Manutenção: o ciclo básico](#o-ciclo-básico).

---

## Sumário

- [O que tem aqui](#o-que-tem-aqui)
  - [O ambiente](#o-ambiente)
  - [Mapa do repositório](#mapa-do-repositório)
  - [Scripts em ~/.local/bin](#scripts-em-localbin)
  - [Temas: Catppuccin Mocha e Noctalia](#temas-catppuccin-mocha-e-noctalia)
  - [Workspaces e monitores](#workspaces-e-monitores)
  - [Atalhos principais](#atalhos-principais)
- [Instalação numa máquina nova](#instalação-numa-máquina-nova)
- [Manutenção](#manutenção)
  - [Como o chezmoi pensa](#como-o-chezmoi-pensa)
  - [O ciclo básico](#o-ciclo-básico)
  - [Comandos do dia a dia](#comandos-do-dia-a-dia)
  - [Prefixos dos nomes de arquivo](#prefixos-dos-nomes-de-arquivo)
  - [Receitas](#receitas)
  - [Antes de cada push](#antes-de-cada-push)
  - [Atualizar programas e plugins](#atualizar-programas-e-plugins)
  - [Quando algo dá errado](#quando-algo-dá-errado)
- [O que fica fora do repositório](#o-que-fica-fora-do-repositório)

---

## O que tem aqui

### O ambiente

| Camada | Programa | Papel |
|---|---|---|
| Sessão | **uwsm** | inicia o Hyprland como sessão do systemd no login do tty1 (sem gerenciador de login) |
| Compositor | **Hyprland** 0.57 | janelas, workspaces, monitores e atalhos; config em **Lua** |
| Shell gráfico | **Noctalia** | barra, launcher, notificações, bloqueio de tela, wallpaper e tema |
| Terminal | **Ghostty** | terminal padrão (JetBrainsMono Nerd Font) |
| Multiplexador | **tmux** 3.8 | sessões persistentes; prefixo **Ctrl+Space** |
| Shell | **zsh** | config em `~/.config/zsh` (via `ZDOTDIR`), modo vi, fzf-tab |
| Prompt | **Starship** | prompt de 2 linhas no estilo padrão do Starship (`pasta on  branch [status] via  versão took 3s`), com os ícones do preset nerd-font-symbols |
| Editor | **Neovim** + LazyVim | tema catppuccin-mocha |
| Ferramentas de terminal | fzf, fd, bat, eza, zoxide, yazi, lazygit, ripgrep | busca, preview, `ls`, `cd` inteligente, arquivos, git |
| Linguagens | **mise** | Go (latest) e Node (LTS) |
| Jogos | Steam, Heroic, gamescope, gamemode, MangoHud, GE-Proton | jogos no 10 da tela em foco, Big Picture onde você pedir, HDR na TV |

O hardware é uma placa NVIDIA (RTX 5080, `nvidia-open`), um monitor Full HD 144 Hz (`DP-2`) e uma TV LG C4 (`HDMI-A-1`) usada só para jogar.

### Mapa do repositório

No chezmoi, o nome de cada arquivo no repositório diz onde ele vai parar: `dot_config/` vira `~/.config/`, e `private_dot_local/` vira `~/.local/` com permissão só para o seu usuário. Veja [Prefixos dos nomes de arquivo](#prefixos-dos-nomes-de-arquivo).

```
.
├── .chezmoiexternal.toml        clona o TPM (plugins do tmux)
├── .chezmoiignore               arquivos do repo que NÃO vão para ~ (este README)
├── .chezmoitemplates/
│   └── starship-palette.toml    paleta Catppuccin Mocha padrão do Starship
├── run_onchange_after_bat-cache.sh.tmpl   monta o cache de temas do bat
├── run_onchange_after_mime-defaults.sh     apps padrão do xdg-open (pastas: yazi no Ghostty)
├── ES-DE/custom_systems/        ~/ES-DE: sistemas e regras de emulador do ES-DE (Switch 2)
├── dot_gitconfig                ~/.gitconfig (e-mail noreply, credenciais via gh)
├── dot_zshenv                   ~/.zshenv: só aponta o ZDOTDIR para ~/.config/zsh
├── dot_config/                  ~/.config/
│   ├── hypr/                    Hyprland (Lua)
│   │   ├── hyprland.lua         ponto de entrada: carrega os outros arquivos
│   │   ├── variables.lua        apps, telas e valores usados pelos outros arquivos
│   │   ├── dot_luarc.json       o Neovim completa e valida a API hl
│   │   ├── create_noctalia.lua  cores das bordas (gerado pelo Noctalia)
│   │   ├── hyprland/            um arquivo por seção: monitors, general, decoration,
│   │   │                        animations, input, misc, execs, rules, keybinds
│   │   │   ├── animations/      conjuntos de animação (smooth, caelestia, omarchy,
│   │   │   │                    spring, macos, snappy); o ativo se escolhe em
│   │   │   │                    `animations` no variables.lua
│   │   │   └── apps/            o que é de um app só (jogos, Steam, Discord, Bitwarden,
│   │   │                        Obsidian, PiP, Noctalia)
│   │   └── utils/               functions.lua (bind, run, window, tags) e
│   │                            workspaces.lua (10 por tela: monitor 1–10, TV 11–20)
│   ├── uwsm/env, env-hyprland   variáveis de ambiente da sessão (NVIDIA, Qt, PATH...)
│   ├── noctalia/config.toml     config do Noctalia (tema, templates, notificações)
│   ├── ghostty/                 config do terminal + tema
│   ├── tmux/tmux.conf           tmux (atalhos, barra, plugins)
│   ├── zsh/                     .zshrc, .zprofile e conf.d/ (um arquivo por assunto)
│   ├── nvim/                    LazyVim (com lazy-lock.json)
│   ├── modify_starship.toml     prompt (template de modificação, veja Temas)
│   ├── lazygit/                 config + tema
│   ├── yazi/, bat/, fzf/, eza/  temas e config das ferramentas
│   ├── mise/config.toml         versões de Go e Node
│   └── MangoHud/                HUD de FPS nos jogos
└── private_dot_local/
    ├── bin/                     ~/.local/bin: scripts próprios (abaixo)
    └── private_share/applications/   atalhos de menu do Lichii, dos recomps e do yazi no Ghostty
```

**zsh por assunto** (`dot_config/zsh/conf.d/`): `options`, `history`, `completion`, `vi-mode`, `aliases`, `tools` (starship, zoxide, fzf, mise, bat como `man`) e `plugins` (autosuggestions e syntax-highlighting, sempre por último). O `.zshrc` carrega todos em ordem.

O `.zprofile` abre o Hyprland sozinho ao fazer login no **tty1**.

### Scripts em ~/.local/bin

| Script | O que faz | Como se usa |
|---|---|---|
| `launch-or-focus` | foca a janela do app se já estiver aberta; senão, abre | usado pelos atalhos dos apps de janela única (Discord, Obsidian, OBS, k9s, Heroic) |
| `keybinds` | lista todos os atalhos do Hyprland num fzf pesquisável | **SUPER+F1** |
| `tmux-sessionizer` | escolhe uma pasta do zoxide e abre/entra na sessão tmux dela | **Ctrl+Space f** no tmux |
| `tv-toggle` | liga/desliga a TV no Hyprland, no 4K de maior taxa que o driver oferecer | **SUPER+ALT+O**, ou `tv-toggle on\|off` |
| `steam-bigpicture` | Steam Big Picture no workspace atual da tela pedida, em tela cheia, sem gamescope; com `--gamescope`, a Steam inteira dentro do gamescope (na TV, com HDR) | **SUPER+CTRL+SHIFT+G** no monitor, **+ALT** na TV; **SUPER+CTRL+SHIFT+B** e **+ALT** com gamescope (na TV, com HDR); `--here` na tela em foco; `--sdr`, `--itm`, `--sdr-nits N` para o HDR do gamescope; `--desktop` abre a Steam normal (**SUPER+SHIFT+G**). O mesmo atalho fecha o Big Picture (ou sai do gamescope). O HUD do gamescope é o mangoapp, oculto até o **SUPER+F12** |
| `hdr` | roda um jogo com HDR quando ele abre na TV (Wine Wayland do GE-Proton); em outra tela, normal | opção de inicialização: `hdr gamemoderun %command%`; terminal: `hdr ./jogo`; Heroic: `hdr` no wrapper |
| `gs-run` | roda um jogo dentro do gamescope, no modo da tela em foco; na TV, com HDR | opção de inicialização: `gs-run gamemoderun %command%`; `--sdr`, `--itm`, `--sdr-nits N` |
| `update-ge-proton` | baixa a versão mais nova do GE-Proton para a Steam | `update-ge-proton` (depois reinicie a Steam) |

A função de shell **`tdl`** (em `aliases.zsh`) monta um layout de trabalho no tmux: Neovim à esquerda, a IA à direita (padrão `claude`) e um terminal embaixo. Uso: `tdl` ou `tdl claude`.

### Temas: Catppuccin Mocha e Noctalia

Esta é a parte menos óbvia do repositório.

O **Noctalia** colore os outros programas: quando o tema dele muda, ele reescreve os arquivos de tema do Ghostty, Hyprland, fzf, bat, yazi, lazygit e Starship. O tema dele hoje é o Catppuccin escuro, que gera exatamente a paleta **Catppuccin Mocha**.

Quero que os dotfiles funcionem **com e sem** o Noctalia. Por isso cada arquivo de tema está no repositório com o Mocha, de um destes dois jeitos:

| Tipo | Arquivos | Comportamento |
|---|---|---|
| `create_` | `ghostty/themes/noctalia`, `hypr/noctalia.lua`, `fzf/themes/noctalia.sh`, `bat/themes/noctalia.tmTheme`, `yazi/flavors/noctalia.yazi/`, `lazygit/themes/noctalia.yml` | o chezmoi cria o arquivo **só se ele não existir**. Depois disso, nunca mais mexe nele: o Noctalia pode reescrever à vontade |
| `modify_` | `starship.toml`, `lazygit/config.yml` | o Noctalia escreve o tema **dentro** desses arquivos. O chezmoi monta o arquivo com a config do repositório e **mantém o bloco de tema que já estiver no arquivo**. Se não houver bloco (instalação nova), usa o Mocha |

Na prática:
- **Instalação nova sem o Noctalia:** tudo sai em Catppuccin Mocha.
- **Com o Noctalia:** ele troca os temas quando você muda o tema dele, e o `chezmoi diff` continua limpo, sem nada para "re-adicionar".
- **Os arquivos se chamam `noctalia`** mesmo com o Mocha dentro, porque são os nomes que o Noctalia sobrescreve e que as configs (`theme = noctalia`) procuram.
- **Atenção:** os dois arquivos `modify_` (`starship.toml` e `lazygit/config.yml`) só se editam pelo repositório, com `chezmoi edit`. O `chezmoi re-add` **não funciona** neles. Veja [Editar um arquivo modify_](#editar-um-arquivo-modify_).

Ficam de fora o Neovim, que usa o plugin `catppuccin-mocha` direto, e o tmux, que usa o plugin `catppuccin/tmux`.

### Workspaces e monitores

- **Dez workspaces por tela.** Cada tela tem um bloco de 10, na ordem de `screens.order` no `variables.lua`: monitor **1–10**, TV **11–20**. Com o QHD, ele fica com o 1–10, o monitor passa a 11–20 e a TV a 21–30 (as janelas mudam de número sozinhas). A barra mostra 1–10 em todas.
- **Nenhum app tem número fixo:** a janela abre no workspace em que você está, inclusive o Big Picture. A exceção são os jogos, que abrem no 10 da tela.
- **SUPER+número** vai para o workspace da tela em foco; a tecla 0 é o 10. **SUPER+ALT+número** vai à próxima tela, em ciclo. A barra mostra sempre o 1–5 de cada tela, mesmo vazios (regras `persistent`; a quantidade é `persistentWorkspaces` no `variables.lua`), e do 6 ao 10 só os que têm janela.
- **Workspaces especiais** abrem por cima de tudo, e a mesma tecla os esconde. Se o app não está rodando, a tecla abre; se está em outro workspace, traz. Só o que é de olhar e fechar fica num especial (como no Omarchy); os apps de cada um ficam na tabela `toggles` do `hypr/variables.lua`:

  | Tecla | Especial | App |
  |---|---|---|
  | SUPER+S | `scratch` | o que você mandar (SUPER+ALT+S); com outro especial aberto, a tecla fecha esse |
  | SUPER+M | `music` | Spotify |
  | CTRL+SHIFT+Escape | `sysmon` | btop |

  Para tirar uma janela do especial e pô-la no workspace normal: **SUPER+CTRL+SHIFT+↓**.
- **Discord (SUPER+SHIFT+D) e Obsidian (SUPER+SHIFT+O)** são janelas normais: a tecla abre o app ou vai até a janela dele, onde ela estiver (`launch-or-focus`).
- **A TV começa desligada no Hyprland** porque, em espera, ela continua "conectada" pelo HDMI. **SUPER+ALT+O** (`tv-toggle`) a liga e desliga; ela é uma tela como as outras. Ao desligar, os workspaces dela com janelas vão para o monitor, aparecem como "TV 3" e voltam quando ela religa. Um reload da config não a desliga.
- **Jogos** abrem no **10 da tela em foco** (SUPER+0), um workspace só deles: no monitor o 10, na TV o 10 dela (id 20). Eles ganham VRR, permissão de tearing e tela que não apaga. As regras ficam em `hypr/hyprland/apps/games.lua`, no padrão de tags, sem eventos (formato do CachyOS): a lista de classes da tag `game` (`steam_app_*`, `gamescope`, `*.exe`, recomps) e, no Lichii, só a janela principal com um jogo rodando, pelo título. Dos `.exe`, instaladores, atualizadores e launchers de loja (Battle.net, EA, Ubisoft, GOG, Rockstar) não contam como jogo. O gamescope ganha os efeitos de jogo, mas fica no workspace onde abriu: o Big Picture no gamescope nasce no workspace que a tela pedida mostra. Assim o jogo nunca cai em cima do Big Picture: só cabe uma janela em tela cheia por workspace. As janelas da Steam nascem flutuando (`apps/steam.lua`, como no Omarchy), e o Big Picture fica em tela cheia no workspace onde abriu. Com um jogo aberto, a Steam do desktop aparece pela overlay (Shift+Tab) ou trocando de workspace.
- **HDR só na TV:** o Hyprland troca a TV para HDR quando um jogo HDR fica em tela cheia e volta ao SDR ao sair (`cm_auto_hdr`); o monitor nunca liga HDR (`supports_hdr = -1`). O jogo pede HDR pelo `hdr` (GE-Proton) ou pelo gamescope (`gs-run`, `steam-bigpicture --gamescope`); o HDR em si se liga no menu do jogo.
- **Monitor QHD futuro:** ponha a conexão em `screens.qhd` no `variables.lua` e o modo em `hyprland/monitors.lua`; `utils/workspaces.lua` renumera o resto sozinho.

**Numa máquina com outras telas, edite `screens` no `variables.lua` e os modos em `hyprland/monitors.lua`.** Os nomes das conexões aparecem em `hyprctl monitors all`.

### Atalhos principais

A lista completa está sempre a um **SUPER+F1** de distância, porque ela é gerada a partir das descrições do `hypr/hyprland/keybinds.lua`.

**Hyprland** (SUPER = tecla Windows)

| Atalho | Ação |
|---|---|
| SUPER+Return | terminal (Ghostty) |
| SUPER+ALT+Return | terminal já no tmux (sessão `main`) |
| SUPER+Space | launcher do Noctalia |
| SUPER+SHIFT+B / F / N | navegador (sempre janela nova) / yazi / Neovim |
| SUPER+S / M | especiais: scratchpad / Spotify (veja Workspaces) |
| SUPER+SHIFT+D / O | Discord / Obsidian (abre ou vai até a janela) |
| CTRL+SHIFT+Escape | especial do btop |
| SUPER+SHIFT+G, SUPER+SHIFT+ALT+G | Steam (também sai do gamescope), Heroic |
| SUPER+CTRL+SHIFT+G | Big Picture no workspace atual do monitor; de novo, fecha; aberto em outro lugar, traz para cá |
| SUPER+CTRL+SHIFT+ALT+G | Big Picture no workspace que a TV mostra (liga a TV se preciso) |
| SUPER+CTRL+SHIFT+B, +ALT | Big Picture dentro do gamescope, no monitor ou na TV (com HDR); de novo, sai para o desktop |
| SUPER+F12 (gamescope) | mostrar/esconder o HUD do mangoapp, em qualquer jogo (começa escondido; com ele visível, o Shift direito+F12 também esconde) |
| SUPER+Q ou SUPER+W | fechar janela; SUPER+CTRL+Q fecha todas do workspace; SUPER+CTRL+ALT+Q mata a janela clicada (app travado) |
| SUPER+F / ALT+F / T | tela cheia / maximizar / flutuar |
| SUPER+CTRL+F | tela cheia dentro do tile (o app acha que está em tela cheia) |
| SUPER+P / ALT+P | pop-out que vai e volta (flutua, fixa em todos os workspaces) / pop-out pequeno no canto |
| SUPER+ALT+Space | alterna o foco entre janelas em tiling e flutuantes (de novo nas flutuantes: a próxima) |
| SUPER+Z / X (segurando) | mover / redimensionar a janela com o mouse, sem botão |
| SUPER+hjkl ou setas | focar a janela vizinha; com SHIFT, mover; com CTRL, trocar de lugar; com ALT, redimensionar (hjkl e setas fazem sempre o mesmo) |
| SUPER+G | grupo (abas numa área): liga/desliga; SUPER+ALT+Tab / SUPER+ALT+SHIFT+Tab troca de aba; SUPER+CTRL+SHIFT+hjkl põe a janela no grupo vizinho |
| SUPER+1…0 | workspace; com SHIFT, leva a janela junto; com CTRL, manda a janela e fica |
| SUPER+Tab ou Page_Down | próximo workspace do monitor |
| SUPER+O, SUPER+ALT+O | focar o outro monitor; ligar/desligar a TV |
| SUPER+N | central de controle do Noctalia (SUPER+CTRL+A: áudio; SUPER+CTRL+B: bluetooth) |
| SUPER+CTRL+S | print de uma região (com SHIFT, a tela inteira; com ALT, a janela; SUPER+CTRL+E, com anotações; SUPER+CTRL+C, seletor de cor) |
| SUPER+V | histórico da área de transferência |
| SUPER+CTRL+M / SUPER+CTRL+SHIFT+M | mudo / microfone mudo |
| SUPER+Escape | bloquear a tela (SUPER+ALT+Escape: volta o bloqueio se o Noctalia cair) |
| SUPER+SHIFT+Escape ou CTRL+ALT+Delete | menu de sessão |
| SUPER+ALT+F1 | desliga todos os atalhos (VM, área de trabalho remota); de novo, liga |
| SUPER+CTRL+R | recarregar a config do Hyprland |
| SUPER+F1 ou SUPER+/ | cola de atalhos, agrupada por categoria |

**tmux** (prefixo **Ctrl+Space**: aperte, solte, depois a tecla)

| Atalho | Ação |
|---|---|
| Ctrl+Space `\|` / `-` | dividir à direita / embaixo |
| Ctrl+Space c | nova janela na pasta atual |
| Ctrl+Space f | sessionizer (pastas do zoxide) |
| Ctrl+Space g | lazygit num popup |
| Ctrl+Space x / k / X | fechar pane / janela / sessão |
| Ctrl+Space R | renomear a sessão |
| Ctrl+Space ? | lista de atalhos com busca: os com "Ctrl+Space" na frente precisam do prefixo, os outros funcionam direto |
| Ctrl+Space r | recarregar a config |
| Ctrl+Space Ctrl+s / Ctrl+r | salvar / restaurar as sessões (tmux-resurrect) |
| Ctrl+Space I / U | instalar / atualizar plugins (TPM) |
| Alt+1…9 | ir para a janela 1–9 (**sem prefixo**) |
| Alt+←/→, Alt+↑/↓ | janela anterior/próxima; sessão anterior/próxima |
| Alt+Enter, Alt+Shift+Enter | dividir embaixo / à direita |
| Alt+Escape | fechar pane |
| Ctrl+h/j/k/l | mudar de pane (e de split do Neovim, pelo vim-tmux-navigator) |
| Alt+s, Alt+w | árvore de sessões / janelas |

**Com prefixo e sem prefixo.** No tmux, cada atalho fica numa tabela. O `bind` comum vai para a tabela `prefix`: só vale depois do Ctrl+Space. O `bind -n` vai para a tabela `root`: vale sempre, mas toma a tecla de todos os programas do pane. Por isso, os sem prefixo usam Alt ou Ctrl+Alt, que os programas quase não usam.

**Sessões que voltam depois de um kill.** O tmux-continuum restaura o último retrato salvo toda vez que o tmux abre, e só salva um retrato novo a cada 15 minutos com o tmux aberto. Uma sessão morta volta se o tmux fechar antes do próximo salvamento. Para isso não acontecer, aperte **Ctrl+Space Ctrl+s** depois de matar a sessão.

**zsh**: Ctrl+R busca no histórico, Ctrl+T busca arquivos, Alt+C busca pastas (os três pelo fzf). Tab abre as opções de completação no fzf (fzf-tab); dentro do tmux, elas abrem num popup flutuante perto do cursor, com no mínimo 80×12 e espaço extra para a prévia no `cd`/`z`. `z pasta` pula para uma pasta pelo zoxide; `y` abre o yazi e, ao sair com `q`, o shell fica na pasta onde você estava no yazi.

---

## Instalação numa máquina nova

Pré-requisito: um Arch Linux instalado, com usuário, rede, `sudo` e o driver de vídeo.

### 1. Pacotes

Pacotes dos repositórios oficiais:

```sh
sudo pacman -S --needed \
  git chezmoi github-cli \
  zsh zsh-autosuggestions zsh-syntax-highlighting starship zoxide \
  fzf fd ripgrep bat eza yazi lazygit neovim tmux ghostty \
  hyprland uwsm xdg-desktop-portal-hyprland noctalia wl-clipboard \
  ttf-jetbrains-mono-nerd mise 7zip \
  steam gamescope gamemode mangohud
```

Um ajudante para o AUR (paru) e os pacotes que só existem lá:

```sh
sudo pacman -S --needed base-devel
git clone https://aur.archlinux.org/paru.git /tmp/paru && (cd /tmp/paru && makepkg -si)
paru -S fzf-tab heroic-games-launcher-bin
```

Opcionais, para desenvolvimento:

```sh
sudo pacman -S docker docker-compose docker-buildx kubectl k9s kind helm
```

> **Nota:** ninguém mantém esta lista sozinho. Quando instalar um programa novo que a config usa, acrescente-o aqui.

### 2. Aplicar os dotfiles

```sh
chezmoi init --apply mauriciotp
```

O que esse comando faz:
1. clona `github.com/mauriciotp/dotfiles` em `~/.local/share/chezmoi`, a **fonte**;
2. copia cada arquivo para o lugar certo em `~`, o **destino**;
3. clona o TPM em `~/.config/tmux/plugins/tpm` (pelo `.chezmoiexternal.toml`);
4. roda o script que monta o cache de temas do bat.

Quer ver antes o que ele vai fazer? Rode em dois passos:

```sh
chezmoi init mauriciotp     # só clona
chezmoi diff                # mostra o que mudaria em ~
chezmoi apply -v            # aplica, mostrando cada arquivo
```

### 3. zsh como shell padrão

```sh
chsh -s /usr/bin/zsh
```

Saia e entre de novo. Ao fazer login no **tty1**, o `.zprofile` abre o Hyprland sozinho, pelo uwsm.

### 4. Ajustes desta máquina

- **Telas:** confira os nomes em `hyprctl monitors all` e ajuste `~/.config/hypr/monitors.lua` com `chezmoi edit ~/.config/hypr/monitors.lua`.
- **Sem NVIDIA, ou numa VM:** comente as três linhas da NVIDIA em `~/.config/uwsm/env`.

### 5. Primeira abertura de cada programa

| Programa | O que fazer |
|---|---|
| tmux | abra o tmux e aperte **Ctrl+Space I** para instalar os plugins (catppuccin, resurrect, continuum, vim-tmux-navigator) |
| Neovim | abra `nvim`: o LazyVim instala os plugins nas versões do `lazy-lock.json` |
| mise | `mise install` instala o Go e o Node |
| GitHub | `gh auth login`; o `.gitconfig` usa o `gh` como credencial |
| Steam | abra uma vez, depois rode `update-ge-proton` e reinicie a Steam. Em cada jogo, nas opções de inicialização: `gamemoderun %command%` |
| Heroic | Configurações → padrão dos jogos: ligue **GameMode**; o MangoHud, só no jogo que for medir |
| Noctalia | já sobe com a sessão. Os temas que ele gera substituem o Mocha padrão |

### 6. Emulador Lichii (opcional)

O AppImage não fica no repositório. O atalho de menu só aparece quando o arquivo estiver no lugar certo:

```sh
mkdir -p ~/Games/Emulators/Apps ~/Games/Emulators/Switch2/{ROMs,Updates,DLC,Mods}
mv ~/Downloads/<arquivo>.AppImage ~/Games/Emulators/Apps/lichii.AppImage
chmod +x ~/Games/Emulators/Apps/lichii.AppImage

# ícone: extraído do próprio AppImage (é um arquivo SquashFS), sem executá-lo
icon=usr/share/icons/hicolor/256x256/apps/io.github.zortos293.lichii.png
7z e ~/Games/Emulators/Apps/lichii.AppImage "$icon" -o"$HOME/.local/share/icons/hicolor/256x256/apps"
```

O atalho abre o emulador em X11 (`QT_QPA_PLATFORM=xcb`), que funciona melhor que o Wayland. Aberto pelo menu, o Lichii fica no workspace atual; com um jogo rodando, a janela vira jogo pelo título (tag `game`), e aberto já com o jogo (pelo ES-DE) vai para o 10. O gamemode é ligado pelo próprio Lichii ao abrir o jogo (opção `enable_gamemode`, ligada por padrão, em `~/.config/eden/qt-config.ini`); para conferir, `gamemoded -s` com o jogo aberto.

**Pastas dos jogos de emulador** (em inglês, uma por plataforma):

```
~/Games/Emulators/
  Apps/               os emuladores (AppImages); um emulador pode servir a mais de uma plataforma
  Switch2/            uma pasta por plataforma: Switch2, PS4, PS5...
    ROMs/             suas cópias dos jogos (.nup, .nsp, .xci): só leitura
    Updates/          atualizações separadas do jogo
    DLC/              conteúdo adicional
    Mods/             mods, uma subpasta por jogo
```

Os `.nup` já trazem uma atualização: o `[v131072]` no nome é a versão dela (o README do Hookshot pede o Zelda com "update v131072"). Por isso eles ficam em `ROMs/`, não em `Updates/`. Para uma plataforma nova, repita a pasta com as mesmas quatro subpastas.

### 6b. ES-DE: os emuladores num só lugar (opcional)

O ES-DE (`emulationstation-de`, do AUR) lista os jogos de todas as plataformas e abre cada um no emulador certo. Os arquivos em `~/ES-DE/custom_systems/` vêm deste repositório:

| Arquivo | O que define |
|---|---|
| `es_systems.xml` | os sistemas que faltam no ES-DE ou que mudam: hoje o `switch2` (Nintendo Switch 2), com os jogos em `~/Games/Emulators/Switch2/ROMs` (`.nup`) |
| `es_find_rules.xml` | onde achar cada emulador (`LICHII`: o AppImage em `Emulators/Apps`, em X11) |

O jogo abre com `lichii.AppImage -f -g <jogo>` (tela cheia, direto no jogo); o gamemode vem do próprio Lichii, só no jogo, não no ES-DE. O resto da config do ES-DE (`~/ES-DE/settings/es_settings.xml`, listas de jogos, imagens baixadas) é escrito pelo próprio ES-DE e fica fora do repositório.

**Abrir pela Steam** (controle pelo Steam Input, e a Steam desliga as teclas falsas do controle):
1. Steam → **Adicionar um jogo** → **Adicionar um jogo não-Steam** → marque **ES-DE**.
2. Nas propriedades, **sem** opções de inicialização: o gamemode vem de cada emulador.

**Plataforma nova:** crie `~/Games/Emulators/<Plataforma>/{ROMs,Updates,DLC,Mods}`; copie o bloco `<system>` do pacote (`/usr/share/es-de/resources/systems/linux/es_systems.xml`) para o `es_systems.xml.tmpl`, troque o `<path>` para a pasta `ROMs`. Antes, veja se o emulador tem a opção de gamemode (o Lichii e o RetroArch têm) e ligue nela. Se não tiver, crie no `es_find_rules.xml.tmpl` um emulador `GAMEMODERUN` com a regra `systempath` `gamemoderun` e ponha `%PRECOMMAND_GAMEMODERUN%` antes do `%EMULATOR_...%`. Se o emulador for um AppImage em `Emulators/Apps`, acrescente a regra dele no `es_find_rules.xml.tmpl`. A doc completa está no `INSTALL.md` do ES-DE (seções es_systems.xml e es_find_rules.xml).

### 7. Recomps (opcional)

Um recomp é um jogo de console recompilado para rodar nativo no PC. O builder de cada projeto monta o jogo **a partir da sua cópia** (por exemplo, um `.nup` em `~/Games/Emulators/Switch2/ROMs/`). Nem o builder nem o jogo ficam no repositório.

```
~/Games/
  Emulators/          emuladores e jogos por plataforma (veja a seção 6)
  Recomps/
    Builders/         AppImages dos builders, com o nome original (o launcher usa o arquivo para atualizar)
    Longshot/         Zelda: Ocarina of Time
    mkw-recomp/       Mario Kart World
    <projeto>/        um por recomp
```

**Longshot (Zelda: Ocarina of Time):** o sucessor do Hookshot. O Longshot Launcher (AppImage, de longshot.magicbean.dev) monta o jogo e o atualiza.

1. Baixe o `LongshotLauncher-*-x86_64.AppImage` para `~/Games/Recomps/Builders/` e rode (`chmod +x` antes).
2. Monte o jogo a partir do `.nup` em `~/Games/Emulators/Switch2/ROMs/`. O launcher cria a pasta `~/Games/Recomps/rc` (o nome do canal); com o launcher e o jogo fechados, renomeie para `Longshot` e troque o caminho em dois lugares:
   - `"folder"` em `~/.local/share/longshot/launcher/builds.json`;
   - `builder=` em `~/Games/Recomps/Longshot/longshot_version.txt` (o AppImage em `Builders/`).
3. Apague as entradas que o launcher cria, `~/.local/share/applications/longshot.desktop` e a cópia em `~/Desktop`: elas abrem o launcher, e no menu fica só a do jogo.

| Para quê | Como |
|---|---|
| jogar | a entrada **Zelda: Ocarina of Time** do menu (`dev.magicbean.Longshot.desktop`, deste repositório): roda o AppImage com `--play`, que abre o jogo direto, com `gamemoderun` (o Longshot não liga o gamemode sozinho) |
| atualizar | o AppImage em `~/Games/Recomps/Builders/`, que abre o launcher com o botão **Update** |

Saves em `~/.local/share/longshot/save`, fora da pasta do jogo: copie antes de cada update. O launcher também importa saves do Hookshot e dos emuladores.

**mkw-recomp (Mario Kart World):** o AppImage (de github.com/adriadam10/mkw-recomp) é o launcher e também o jogo: a pasta em `Recomps/` guarda só o que ele monta.

1. Baixe o `mkw-recomp-*-x86_64.AppImage` para `~/Games/Recomps/Builders/` e rode (`chmod +x` antes).
2. No launcher, escolha a pasta `~/Games/Recomps/mkw-recomp` e monte o jogo a partir do `.nup` em `~/Games/Emulators/Switch2/ROMs/`. O caminho fica em `game_dir`, no `~/.local/share/mkw-recomp/mkw.ini`.
3. Copie o ícone para a pasta do jogo (a entrada do menu aponta para ele): `cd /tmp && ~/Games/Recomps/Builders/mkw-recomp-*.AppImage --appimage-extract mkw-recomp.png && cp squashfs-root/mkw-recomp.png ~/Games/Recomps/mkw-recomp/`.

| Para quê | Como |
|---|---|
| jogar | a entrada **Mario Kart World** do menu (`mkw-recomp.desktop`, deste repositório): roda o AppImage com `--play`, que abre o jogo direto, com `gamemoderun` |
| configurar, mods, atualizar | o AppImage em `~/Games/Recomps/Builders/`, que abre o launcher |

O nome do AppImage leva a versão: se ela mudar, troque o `$builder` no `mkw-recomp.desktop.tmpl`. O mesmo vale para o Longshot (`dev.magicbean.Longshot.desktop.tmpl`).

**Um recomp novo:**
1. Baixe o builder só da página de releases do projeto e confira o `sha256`.
2. Monte o jogo em `~/Games/Recomps/<projeto>`.
3. Descubra a classe da janela (`hyprctl clients` com o jogo aberto) e acrescente na lista da tag `game` em `hypr/hyprland/apps/games.lua`.
4. Copie o `.desktop.tmpl` do Longshot em `private_dot_local/private_share/applications/`, com o nome `<classe>.desktop.tmpl`, e troque os caminhos. O padrão do `Exec` é `gamemoderun <AppImage> --play`. Valide com `desktop-file-validate`.
5. Se o jogo foi montado em outro lugar: com ele fechado, `mv` da pasta para `~/Games/Recomps/<projeto>`, e troque o caminho na configuração do builder e na entrada que o builder criou.

---

## Manutenção

### Como o chezmoi pensa

Existem **duas cópias** de cada arquivo:

```
  FONTE (o repositório)                         DESTINO (o que os programas leem)
  ~/.local/share/chezmoi/dot_config/tmux/tmux.conf   ──apply──▶   ~/.config/tmux/tmux.conf
                                                ◀──re-add──
```

- A **fonte** é a verdade: é ela que vai para o git e para o GitHub.
- O **destino** é só uma cópia. Se você editar `~/.config/tmux/tmux.conf` direto e não fizer nada, a próxima `chezmoi apply` **desfaz** a sua edição.
- Por isso, toda mudança termina na fonte. Há dois caminhos:
  - **(A) editar na fonte e aplicar:** `chezmoi edit` → `chezmoi apply`. É o caminho recomendado;
  - **(B) editar no destino e trazer de volta:** edita em `~` → `chezmoi re-add`.

O git é só o histórico da fonte. O chezmoi não faz commit sozinho.

### O ciclo básico

Toda mudança segue os mesmos passos:

```sh
# 1. editar (abre a FONTE no $EDITOR; ao salvar e fechar, aplica: --apply)
chezmoi edit --apply ~/.config/tmux/tmux.conf

# 2. testar o programa (recarregar o tmux: Ctrl+Space r)

# 3. ver o que mudou no repositório
chezmoi git -- status
chezmoi git -- diff

# 4. commit (mensagem em inglês, um commit por mudança)
chezmoi git -- add -A
chezmoi git -- commit -m "tmux: describe the change"

# 5. enviar para o GitHub (depois da busca de segredos, veja abaixo)
chezmoi git -- push
```

`chezmoi git -- <comando>` é o próprio `git` rodando dentro da fonte. O mesmo vale para `chezmoi cd` seguido de `git` normal.

### Comandos do dia a dia

**Ver o estado**

| Comando | O que faz |
|---|---|
| `chezmoi status` | lista os arquivos em que fonte e destino diferem. Vazio quer dizer tudo em ordem. A 1ª letra é o que mudou desde o último apply; a 2ª, o que o `apply` faria (`M` modificar, `A` adicionar, `D` apagar, `R` rodar script) |
| `chezmoi diff` | mostra **exatamente** o que o `apply` mudaria em `~`. Rode sempre antes de um `apply` em que você não confia |
| `chezmoi managed` | lista todos os arquivos que o chezmoi controla |
| `chezmoi unmanaged` | lista o que está em `~` e o chezmoi **não** controla (útil para achar config que esqueceu de adicionar) |
| `chezmoi source-path ~/.config/tmux/tmux.conf` | mostra onde está a fonte de um arquivo |
| `chezmoi cat ~/.config/starship.toml` | mostra o conteúdo que o chezmoi geraria para o arquivo (útil para os templates) |
| `chezmoi doctor` | confere se a instalação do chezmoi está saudável |

**Mudar arquivos**

| Comando | O que faz |
|---|---|
| `chezmoi edit ARQUIVO` | abre a **fonte** do arquivo no editor; não aplica |
| `chezmoi edit --apply ARQUIVO` | igual, e aplica ao fechar o editor |
| `chezmoi apply` | copia tudo da fonte para `~` e roda os scripts |
| `chezmoi apply -v` | igual, listando cada arquivo |
| `chezmoi apply --dry-run -v` | mostra o que faria, sem fazer |
| `chezmoi apply ARQUIVO` | aplica só aquele arquivo |
| `chezmoi re-add` | traz para a fonte as edições feitas direto em `~` (em todos os arquivos já controlados) |
| `chezmoi re-add ARQUIVO` | igual, só para um arquivo |
| `chezmoi merge ARQUIVO` | quando fonte e destino mudaram os dois: abre um merge de 3 vias |

**Adicionar e remover**

| Comando | O que faz |
|---|---|
| `chezmoi add ~/.config/x/config` | começa a controlar um arquivo: copia de `~` para a fonte |
| `chezmoi add --create ARQUIVO` | adiciona como `create_`: só é criado se não existir |
| `chezmoi add --template ARQUIVO` | adiciona como template (`.tmpl`) |
| `chezmoi forget ARQUIVO` | para de controlar. **O arquivo continua em `~`**; sai só da fonte |
| `chezmoi destroy ARQUIVO` | para de controlar **e apaga** de `~` (cuidado) |

**Repositório e outras máquinas**

| Comando | O que faz |
|---|---|
| `chezmoi cd` | abre um shell dentro da fonte (`exit` para voltar) |
| `chezmoi git -- ...` | roda `git` na fonte sem sair de onde você está |
| `chezmoi update` | `git pull` na fonte e `apply`. É como trazer mudanças feitas em outra máquina |
| `chezmoi apply -R` | aplica e força a atualização dos externos (o TPM) |

### Prefixos dos nomes de arquivo

O nome do arquivo na fonte é a "configuração" do chezmoi:

| Prefixo/sufixo | Significado | Exemplo aqui |
|---|---|---|
| `dot_` | vira `.` | `dot_config/` → `~/.config/` |
| `private_` | permissão só para o seu usuário (700/600) | `private_dot_local/` |
| `executable_` | arquivo executável | `executable_tv-toggle` |
| `create_` | cria só se não existir; depois não mexe | os temas do Noctalia |
| `modify_` | um template recebe o arquivo atual e devolve o novo | `modify_starship.toml` |
| `run_onchange_after_` | script que roda depois do apply, quando o conteúdo dele muda | `run_onchange_after_bat-cache.sh.tmpl` |
| `.tmpl` | template: aceita variáveis como `{{ .chezmoi.homeDir }}` | o atalho do Lichii |
| `.chezmoi*` na raiz | arquivos especiais do chezmoi (não vão para `~`) | `.chezmoiexternal.toml`, `.chezmoiignore` |

**Não renomeie** um arquivo da fonte sem saber o que o prefixo faz. Para mudar só o prefixo, há `chezmoi chattr`, por exemplo `chezmoi chattr +executable ~/.local/bin/x`.

### Receitas

#### Mudar uma config qualquer
```sh
chezmoi edit --apply ~/.config/ghostty/config.ghostty
# testa → commit
```

#### Editei direto em ~ (sem chezmoi edit)
```sh
chezmoi diff                 # o diff aparece "ao contrário": o apply DESFARIA sua edição
chezmoi re-add ~/.config/ghostty/config.ghostty
chezmoi diff                 # agora vazio
```

#### Editar um arquivo `modify_`
Vale para `~/.config/starship.toml` e `~/.config/lazygit/config.yml`.

```sh
chezmoi edit --apply ~/.config/starship.toml
```
- Na fonte, o arquivo começa com 3 ou 4 linhas de template (`{{- ... -}}`), seguidas da config normal. Mexa só na config normal.
- O bloco de cores (a paleta do Starship, o `gui.theme` do lazygit) **não** está na fonte: o chezmoi o mantém do arquivo atual. Para mudar as cores padrão, edite `.chezmoitemplates/starship-palette.toml` ou `dot_config/lazygit/themes/create_noctalia.yml`.
- No Starship:
  - **Ícones como `\uXXXX`** (`symbol = " "`): são caracteres de uso privado do Nerd Font, que editores e ferramentas apagam sem avisar. Ache o código em nerdfonts.com/cheat-sheet; para ver o ícone, `printf '\n'`. Acima de `FFFF`, use `\U` com 8 dígitos (`\U000f1617`).
  - **Cores só com nomes da paleta** (`sky`, `pink`, `peach`, `red`…): o Noctalia liga cada nome a uma cor do tema, e o prompt muda junto. Um número fixo (`208`) não muda.
  - **O que não está no arquivo vem do padrão** (as palavras `on`, `via`, `is`, `took` estão no `format` padrão de cada módulo): `starship print-config git_branch` mostra o que vale de fato, `starship print-config --default git_branch` só o padrão.
- **Não use `chezmoi re-add`** nesses dois. Na fonte, eles não são uma cópia do arquivo, e sim uma receita que monta o arquivo a cada `apply`. Copiar o arquivo por cima destruiria a receita, então o `re-add` os **pula sem avisar**. Uma edição feita direto em `~` some no próximo `apply`.

#### Começar a controlar um programa novo
```sh
chezmoi add ~/.config/programa/config.toml
chezmoi git -- add -A && chezmoi git -- commit -m "programa: add config"
```
Antes de adicionar, confira que o arquivo **não tem senha, token nem caminho pessoal**: o repositório é público. Se o caminho tiver o seu home, use um template com `{{ .chezmoi.homeDir }}`.

#### Adicionar um script em ~/.local/bin
```sh
chezmoi add ~/.local/bin/meu-script      # se ele já for executável, entra como executable_
```

#### Adicionar um atalho no Hyprland
1. `chezmoi edit --apply ~/.config/hypr/hyprland/keybinds.lua`, no bloco certo.
2. Copie uma linha `bind(...)` existente. A descrição em inglês é o que aparece no SUPER+F1.
3. Valide **antes** de recarregar:
   ```sh
   Hyprland --verify-config -c ~/.config/hypr/hyprland.lua
   ```
4. Recarregue: **SUPER+CTRL+R** ou `hyprctl reload`. Isso desliga a TV no Hyprland; ligue de novo com SUPER+ALT+O.
5. Confira se não sobrou erro: `hyprctl configerrors`.

#### Fazer um app flutuar, ou abrir num especial
Descubra a classe da janela com `hyprctl clients` (campo `class:`). As regras diferenciam maiúsculas de minúsculas.
- **Flutuar:** acrescente a classe numa das listas de tag do `hypr/hyprland/rules.lua` (`float`, `float_60_70`...).
- **Num especial** (só app de olhar e fechar, como música e btop): acrescente o app na tabela `toggles` do `hypr/variables.lua`. App de trabalhar junto com outras janelas fica num workspace normal, com uma tecla de `launch-or-focus` (`app(...)` no `keybinds.lua`).
- **Regra só daquele app** (workspace fixo, foco, tamanho): crie `hypr/hyprland/apps/<app>.lua` com `F.window(...)` e ponha o nome na lista do `hypr/hyprland.lua`.

#### Trocar o app padrão de um tipo de arquivo
O `xdg-open` (usado pelos apps em "abrir pasta", "abrir com o padrão" etc.) lê o `~/.config/mimeapps.list`. Esse arquivo fica fora do chezmoi, porque outros apps também o editam; as escolhas ficam no script `run_onchange_after_mime-defaults.sh`, uma linha `xdg-mime default <app>.desktop <tipo>` por tipo:

```sh
xdg-mime query filetype ARQUIVO            # o tipo (ex.: image/png)
xdg-mime query default image/png           # quem abre hoje
chezmoi edit ~/.local/share/chezmoi/run_onchange_after_mime-defaults.sh
chezmoi apply                              # o script roda de novo porque mudou
```

Hoje ele define só as pastas (`inode/directory`): o `yazi-ghostty.desktop` abre o yazi dentro do Ghostty. Apps de terminal (`Terminal=true`, como o `yazi.desktop` do pacote) não funcionam direto no `xdg-open`: ele os roda sem terminal. O launcher do Noctalia não tem esse problema, porque põe esses apps no `$TERMINAL` sozinho.

#### Parar de controlar um arquivo
```sh
chezmoi forget ~/.config/programa/config.toml   # fica no disco, sai do repo
```

#### Trazer mudanças feitas em outra máquina
```sh
chezmoi update -v
```

#### Ver as métricas de um jogo e limitar o FPS
O MangoHud não roda por padrão: os jogos abrem só com o gamemode. É o jeito mais comum na comunidade (README do MangoHud, ArchWiki), e assim um jogo que não se dá com ele não trava sem você saber por quê.

| Onde | Ver as métricas | Parar |
|---|---|---|
| Steam, desktop | opções de inicialização: `mangohud gamemoderun %command%` (começa visível; Shift direito+F12 esconde) | voltar para `gamemoderun %command%` |
| Heroic | nas configurações do jogo, ligue **MangoHud** | desligar a opção |
| Big Picture no gamescope | SUPER+F12, em qualquer jogo (é o mangoapp do gamescope, sem mexer nas opções) | SUPER+F12 |
| Emulador ou recomp | uma vez pelo terminal: `mangohud <programa>` | fechar |

As duas formas leem o mesmo `~/.config/MangoHud/MangoHud.conf`. Logs: Shift esquerdo+F2, gravados no `$HOME`.

**Limite de FPS: 3 abaixo da taxa da tela.** Encostar na taxa da tela tira o jogo do VRR e traz o atraso do V-Sync; 3 abaixo é a recomendação da Blur Busters. Monitor de 144 Hz → **141**; TV a 60 Hz → **57**. O limite fica fora do MangoHud: não pode depender do HUD, e o limitador dele já travou jogos aqui. Por jogo, nesta ordem:

| Caso | Como |
|---|---|
| o jogo tem limitador próprio | **141** no menu do jogo (o melhor: não acrescenta atraso) |
| não tem (Proton) | opções de inicialização: `DXVK_FRAME_RATE=141 VKD3D_FRAME_RATE=141 gamemoderun %command%` (DXVK: DX9 a DX11; VKD3D: DX12) |
| gamescope | nada: o `steam-bigpicture --gamescope` e o `gs-run` passam `-r` = taxa − 3 ao gamescope |
| emuladores e recomps | nada: os jogos rodam a 30 ou 60 |

Com o MangoHud ligado, confira: FPS estável perto de 141, e o menu do monitor mostrando a frequência acompanhando o FPS (o VRR agindo).

#### Desfazer uma mudança
O chezmoi não tem "desfazer"; o git tem:
```sh
chezmoi git -- log --oneline -10                  # acha o commit
chezmoi git -- revert <hash>                      # desfaz aquele commit
chezmoi apply -v                                  # leva o resultado para ~
```
Para descartar uma edição ainda sem commit:
```sh
chezmoi git -- restore dot_config/tmux/tmux.conf && chezmoi apply
```

### Antes de cada push

O repositório é **público**. Antes de `push`, revise o que vai sair:

```sh
chezmoi cd
git log --oneline origin/main..HEAD                 # commits que vão subir
git log origin/main..HEAD --format='%ae %ce' | sort -u   # deve ser só o e-mail noreply
git diff origin/main..HEAD | grep -nEi \
  'ghp_|github_pat_|gho_|sk-[a-z0-9]{20}|AKIA[0-9A-Z]{16}|xox[baprs]-|BEGIN [A-Z ]*PRIVATE KEY|password *[:=]|secret *[:=]|token *[:=]|api[_-]?key'
git grep -n "/home/$USER"                          # caminhos fixos do seu home
exit
```

Se os dois `grep` não mostrarem nada, `chezmoi git -- push`.

Nunca entram no repositório: `~/.config/gh/` (token do GitHub), `~/.kube/` (credenciais de cluster), chaves SSH e arquivos `.env`.

### Atualizar programas e plugins

| O quê | Como | Depois |
|---|---|---|
| Sistema | `paru` (atualiza pacman + AUR) | se o Hyprland atualizou, confira `hyprctl configerrors` |
| Plugins do Neovim | `:Lazy update` no nvim | `chezmoi re-add ~/.config/nvim/lazy-lock.json` e commit (fixa as versões novas) |
| Plugins do tmux | **Ctrl+Space U** | nada: os plugins não ficam no repositório |
| TPM | sozinho a cada 4 semanas no `chezmoi apply`, ou `chezmoi apply -R` | — |
| GE-Proton | `update-ge-proton` | reinicie a Steam e escolha a versão nova no jogo |
| Go / Node | `mise upgrade` | — |
| Tema | troque no Noctalia (SUPER+vírgula) | nada: os arquivos de tema não geram diff |

### Quando algo dá errado

| Sintoma | O que fazer |
|---|---|
| O Hyprland não abre depois do login | vá para o tty2 (**Ctrl+Alt+F2**), entre e rode `journalctl --user -b -u 'wayland-wm*'` |
| Erro de config do Hyprland (aviso vermelho no topo) | `hyprctl configerrors`; corrija com `chezmoi edit` e valide com `Hyprland --verify-config -c ~/.config/hypr/hyprland.lua` |
| `chezmoi status` mostra algo inesperado | `chezmoi diff ARQUIVO` para ver o quê. Se a versão boa é a de `~`, `chezmoi re-add`; se é a do repositório, `chezmoi apply ARQUIVO` |
| "Abrir pasta" de um app não faz nada | `xdg-mime query default inode/directory` tem que responder `yazi-ghostty.desktop`. Se não, rode `chezmoi apply` (o script `run_onchange_after_mime-defaults.sh` define o padrão); para ver o que o `xdg-open` escolhe: `XDG_UTILS_DEBUG_LEVEL=2 xdg-open ~` |
| "Abrir pasta" de um **jogo ou emulador** não abre janela (Ghostty a 100% de CPU) | com o MangoHud (`mangohud %command%`), ele vai no `LD_PRELOAD`, e o que o jogo abre herda; o Ghostty trava com ele. O `yazi-ghostty.desktop` limpa isso (`env -u LD_PRELOAD -u MANGOHUD`); se travou antes da correção, feche os processos `ghostty` presos (`pkill -f "ghostty -e yazi"`) |
| Uma edição sumiu depois de um `apply` | foi feita em `~` sem `re-add`. Recupere pelo histórico do editor; daí em diante use `chezmoi edit` |
| O tmux abre sem cores e sem plugins | o TPM não instalou os plugins: **Ctrl+Space I**. Se nem o TPM existir: `chezmoi apply -R` |
| O bat ignora o tema | `bat cache --build` |
| Um app não vai para o workspace certo | `hyprctl clients`, compare a `class:` com a regra em `hypr/hyprland/rules.lua` ou `hypr/hyprland/apps/` |
| A TV ficou com os workspaces depois de acordar o PC | `hyprctl reload` (SUPER+CTRL+R), que leva tudo de volta ao monitor |
| A TV liga em 4K@60 com um aviso, ou fica sem sinal | o PC ligou com a TV desligada, e o driver da NVIDIA só ofereceu até 4K@60. Com a TV ligada, tire e recoloque o cabo HDMI e aperte SUPER+ALT+O de novo. Reler a porta pelo kernel (`echo detect \| sudo tee /sys/class/drm/card1-HDMI-A-1/status`) não resolve (testado em 2026-11-10). Para conferir: `hyprctl monitors all -j \| jq -r '.[] \| select(.name=="HDMI-A-1") \| .availableModes[]' \| grep 3840x2160` deve listar o 143.98 ou 143.99 |
| Uma sessão do tmux que você matou voltou | o retrato salvo era anterior ao kill: mate de novo e aperte **Ctrl+Space Ctrl+s** |
| O `chezmoi diff` está vazio, mas há mudanças | o `diff` só compara o repositório com os arquivos em `~`. Commits sem push aparecem em `chezmoi git -- status` (`ahead N`) |

---

## O que fica fora do repositório

| O quê | Por quê |
|---|---|
| `~/.config/gh/`, `~/.kube/`, `~/.ssh/` | credenciais |
| `~/.local/state/noctalia/` | estado do Noctalia: o que a interface grava (tem prioridade sobre o `config.toml`), o catálogo de templates |
| temas do GTK, OBS, Heroic e Obsidian | gerados pelo Noctalia e nunca estiveram no repositório |
| plugins do tmux e do Neovim | baixados pelo TPM e pelo lazy.nvim |
| `/etc`, boot, lista de pacotes | fora do `~`; a lista de pacotes está documentada na [Instalação](#1-pacotes) |
| AppImages e jogos | grandes e binários; veja a [instalação do Lichii](#6-emulador-lichii-opcional) e a dos [recomps](#7-recomps-opcional). Os jogos dos recomps são gerados da sua cópia e nunca podem ir para um repositório público |
