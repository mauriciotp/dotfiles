# nvim

Minha configuração do Neovim, baseada no [LazyVim](https://github.com/LazyVim/LazyVim), com o
[Claude Code](https://claude.com/claude-code) integrado ao tmux.

## Instalação

Faz parte dos [dotfiles](../README.md): o `install.sh` da raiz liga esta pasta em `~/.config/nvim`.
Depois é só abrir o `nvim`; o lazy.nvim instala os plugins na primeira abertura.

Requisitos: Neovim ≥ 0.11, git, ripgrep, fd, [Claude Code](https://docs.claude.com/en/docs/claude-code)
(`claude` no `PATH`), tmux ≥ 3.3 e `ss` (iproute2) para a integração com o Claude. Fora do tmux a
integração cai no terminal embutido do snacks.

As versões dos plugins ficam travadas no `lazy-lock.json`. Se um `:Lazy update` quebrar algo,
`:Lazy restore` volta para as versões commitadas. Depois de atualizar de propósito, commite o lock.

## Estrutura

| Caminho                            | O que tem                                                      |
| ---------------------------------- | -------------------------------------------------------------- |
| `lua/config/`                      | bootstrap do lazy.nvim, opções, keymaps e autocmds             |
| `lua/plugins/claudecode.lua`       | spec do Claude Code: opções, atalhos, statusline               |
| `lua/claude/`                      | integração com o Claude: tmux, prompts, placeholders (abaixo)  |
| `lua/plugins/lsp.lua`, `sql.lua`   | `sqls`, inlay hints desligados, sqlfluff lendo o `.sqlfluff`   |
| `lua/plugins/colorscheme.lua`      | catppuccin-mocha                                               |
| `lua/plugins/vim-tmux-navigator.lua` | `<C-h/j/k/l>` navegam entre splits do nvim e panes do tmux   |
| `lazyvim.json`                     | extras do LazyVim habilitados (linguagens, yanky, dial…)       |

## Claude Code

O [claudecode.nvim](https://github.com/coder/claudecode.nvim) abre um servidor WebSocket no nvim
para o Claude ver seleções, receber `@menções` e propor alterações como diffs. Por cima dele,
`lua/claude/` traz os recursos do [opencode.nvim](https://github.com/nickjvandyke/opencode.nvim)
(Ask, Select, prompts prontos, placeholders, operador) no mesmo padrão do plugin: **toda função é
um comando `:ClaudeCode*`** e todo atalho só chama um comando.

| Arquivo              | O que tem                                                              |
| -------------------- | ---------------------------------------------------------------------- |
| `claude/prompts.lua` | registro central dos prompts prontos: o único lugar para criar/editar um |
| `claude/context.lua` | placeholders (`@this`, `@diagnostics`…)                                |
| `claude/tmux.lua`    | Claude num pane do tmux: achar, focar, criar, colar texto              |
| `claude/init.lua`    | Ask, Select, slash commands, operador `ga`; gera comandos e atalhos    |

### Atalhos

Todos ficam sob `<leader>a`. Os marcados com **n/x** funcionam no modo normal (sobre a linha do
cursor; com contagem, `3<leader>ae` pega 3 linhas) e no visual (sobre a seleção). Nos prompts, a
minúscula age sobre o código e a maiúscula é a variante.

| Atalho                      | Comando                          | Ação                                              |
| --------------------------- | -------------------------------- | ------------------------------------------------- |
| **Interação**               |                                  |                                                   |
| `<leader>aa` n/x            | `:ClaudeCodeAsk [texto]`         | escrever uma pergunta (input com `@this: `)       |
| `<leader>as` n/x            | `:ClaudeCodeSelect`              | menu com todos os prompts e ações                 |
| `<leader>a/` n/x            | `:ClaudeCodeCommand [nome]`      | escolher um slash command do Claude               |
| **Prompts**                 |                                  |                                                   |
| `<leader>ae` n/x            | `:ClaudeCodeExplain`             | explicar o código                                 |
| `<leader>aE` n/x            | `:ClaudeCodeExplainDiagnostics`  | explicar os diagnósticos                          |
| `<leader>af` n/x            | `:ClaudeCodeFix`                 | corrigir os diagnósticos                          |
| `<leader>ar` n/x            | `:ClaudeCodeReview`              | revisar (corretude e legibilidade)                |
| `<leader>ad` n/x            | `:ClaudeCodeDocument`            | documentar com comentários                        |
| `<leader>ao` n/x            | `:ClaudeCodeOptimize`            | otimizar (desempenho e legibilidade)              |
| `<leader>ai` n/x            | `:ClaudeCodeImplement`           | implementar                                       |
| `<leader>at` n/x            | `:ClaudeCodeAddTests`            | escrever testes                                   |
| `<leader>aT` n/x            | `:ClaudeCodeRunTests`            | rodar os testes do pacote e corrigir as falhas    |
| **Contexto**                |                                  |                                                   |
| `ga{motion}` / `gaa` / `ga` (visual) | `:ClaudeCodeAdd` / `:ClaudeCodeSend` | anexar um trecho como menção; `.` repete  |
| `<leader>ab`                | `:ClaudeCodeAdd %`               | anexar o buffer (numa árvore de arquivos, o arquivo sob o cursor) |
| `<a-a>` (picker do snacks)  | —                                | anexar os arquivos selecionados no picker         |
| **Sessão**                  |                                  |                                                   |
| `<leader>ac`                | `:ClaudeCodeFocus`               | abrir/focar o Claude (cria um split se não houver) |
| `<leader>aw`                | `:ClaudeCodeOpenWindow`          | abrir o Claude numa janela tmux própria           |
| `<leader>am`                | `:ClaudeCodeSelectModel`         | escolher o modelo (com Claude aberto, manda `/model`) |
| **Diff**                    |                                  |                                                   |
| `<leader>ay`                | `:ClaudeCodeDiffAccept`          | aceitar o diff (**y**es)                          |
| `<leader>an`                | `:ClaudeCodeDiffDeny`            | rejeitar o diff (**n**o)                          |
| `<leader>aD`                | `:ClaudeCodeCloseAllDiffs`       | fechar os diffs pendentes                         |

O status da conexão fica na statusline: o ícone 󰚩 aparece colorido quando o Claude está
conectado a este nvim (`:ClaudeCodeStatus` dá os detalhes).

### Anexar × perguntar

- **Anexar** (`ga`, `<leader>ab`, `<a-a>`): o trecho entra no prompt do Claude como menção e o foco
  vai para lá; você escreve a pergunta no Claude.
- **Perguntar** (`<leader>aa`) e **prompts** (`<leader>ae`, `af`…): o texto é montado no nvim, com
  o contexto, e enviado de uma vez.

### Placeholders

No Ask, nos prompts e nos argumentos de slash commands, estes marcadores são trocados pelo
contexto antes do envio. Exemplo com o cursor na linha 42 de `src/user.go`:

| Placeholder    | Sem seleção                                | Com as linhas 10–20 selecionadas |
| -------------- | ------------------------------------------ | -------------------------------- |
| `@this`        | `@src/user.go#L42`                         | `@src/user.go#L10-20`            |
| `@buffer`      | `@src/user.go`                             | igual                            |
| `@buffers`     | `@src/user.go @src/auth.go` (abertos)      | igual                            |
| `@visible`     | `@src/user.go#L30-75` (o que está na tela) | igual                            |
| `@diagnostics` | erros e avisos do buffer, em texto         | só os da seleção                 |
| `@quickfix`    | itens da lista quickfix, em texto          | igual                            |
| `@marks`       | `@arquivo#Llinha` de cada mark global (A–Z) | igual                           |

`@arquivo#L10-20` é a sintaxe de menção do Claude Code: ele lê o trecho **do disco**, por isso os
buffers citados são salvos antes do envio. Exemplo: `<leader>aa` e
`@this: por que está lento?` enviam `@src/user.go#L10-20: por que está lento?`.

### Prompts

Ficam em [`lua/claude/prompts.lua`](lua/claude/prompts.lua). Para criar um, basta acrescentar um
item; o comando `:ClaudeCode<name>`, o atalho e a entrada no Select são gerados sozinhos:

```lua
{ name = "Explain", key = "<leader>ae", desc = "Explain Code", prompt = "Explique @this e seu contexto…" },
```

### Diffs

Quando o Claude propõe uma alteração, o diff abre numa aba própria e o foco vem para o nvim.
O lado proposto é editável: `]c`/`[c` navegam entre as mudanças, `do` desfaz um trecho, e no fim
`<leader>ay` (ou `:w`) aceita, `<leader>an` (ou `:q`) rejeita. Depois disso o foco volta ao Claude.

Arquivos que o Claude grava direto (modo auto-accept) são recarregados em tempo real enquanto ele
estiver conectado.

### Claude no tmux

Em vez de um terminal dentro do nvim, o Claude roda num **pane do tmux** (`claude/tmux.lua`, um
*terminal provider* do plugin). Como ele é encontrado, em ordem:

1. o processo `claude` **conectado** à porta deste nvim, em qualquer janela ou sessão do tmux
   (descoberto via `ss` e a árvore de processos; vale também para um Claude aberto à mão que rodou
   `/ide`);
2. um pane desta janela criado por este nvim que ainda está subindo;
3. nenhum: cria um split ao lado (38% da largura) ou, com `<leader>aw`, uma janela nova.

Qualquer envio sem Claude aberto cria o pane e entrega o texto ou a menção quando ele conectar.
O texto é colado com bracketed paste (`tmux paste-buffer -p`), então prompts com várias linhas
chegam inteiros; se houver um rascunho no prompt do Claude, o texto é colado no fim dele.
Fora do tmux, a integração cai no terminal embutido do snacks.

#### tmux.conf

A integração funciona com um tmux padrão, mas o bloco "Claude Code" do
[`tmux/tmux.conf`](../tmux/tmux.conf) completa o workflow:

```tmux
# --- Claude Code ---
set -g focus-events on                 # nvim recebe FocusGained -> recarrega arquivos editados pelo Claude
set -g allow-passthrough on            # notificações/OSC do Claude chegam ao terminal
set -s extended-keys on                # Shift+Enter = nova linha no prompt do Claude
set -as terminal-features 'xterm*:extkeys'
set -g history-limit 50000
# prefix + C : abre o Claude ao lado (fora do nvim) e marca o pane
bind C split-window -h -l 38% -c "#{pane_current_path}" "claude" \; set -p @claude 1
# prefix + a : pula para o pane do Claude (janela atual, senão outra janela da sessão)
bind a run-shell "~/.local/bin/tmux-claude-focus '#{pane_id}'"
# tmux-resurrect: ao restaurar a sessão, reabre os panes do Claude com --continue
set -g @resurrect-processes '"~claude->claude --continue"'
```

- `prefix + a` usa o [`tmux/tmux-claude-focus`](../tmux/tmux-claude-focus): procura um pane marcado com `@claude=1` (criado pelo
  nvim ou pelo `prefix + C`) ou rodando `claude`, primeiro na janela atual e depois na sessão.
- Um Claude aberto pelo `prefix + C` não nasce conectado a nenhum nvim: rode `/ide` nele para
  conectar. O nvim também o encontra se estiver na mesma janela.
- O mesmo vale depois de um restore do tmux-resurrect: o nvim reabre numa porta nova, então o
  Claude restaurado com `--continue` precisa de `/ide` para reconectar.

### Ajustes

No topo de `lua/claude/tmux.lua`:

- `AUTO_START_ARGS`: flags de um Claude criado sem flags explícitas (`""` = sessão nova,
  `"--continue"` = retoma a última conversa do projeto);
- `SPLIT_SIZE`: largura do split (padrão `38%`).
