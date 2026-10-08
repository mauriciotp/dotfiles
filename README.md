# nvim

Minha configuração do Neovim, baseada no [LazyVim](https://github.com/LazyVim/LazyVim), com o
[Claude Code](https://claude.com/claude-code) integrado ao tmux.

## Instalação

```sh
git clone git@github.com:mauriciotp/nvim-config.git ~/.config/nvim

# slash commands do Claude usados pelos atalhos <leader>at / <leader>ae
mkdir -p ~/.claude/commands
for f in ~/.config/nvim/claude/commands/*.md; do ln -sfn "$f" ~/.claude/commands/; done

nvim   # o lazy.nvim instala os plugins na primeira abertura
```

Requisitos: Neovim ≥ 0.11, git, [Claude Code](https://docs.claude.com/en/docs/claude-code) (`claude`
no `PATH`), tmux ≥ 3.0 e `ss` (iproute2) para a integração com o Claude. Fora do tmux a integração cai
no terminal embutido do snacks.

As versões dos plugins ficam travadas no `lazy-lock.json`. Se um `:Lazy update` quebrar algo,
`:Lazy restore` volta para as versões commitadas.

## Estrutura

| Caminho                            | O que tem                                                      |
| ---------------------------------- | -------------------------------------------------------------- |
| `lua/config/`                      | bootstrap do lazy.nvim, opções, keymaps e autocmds             |
| `lua/plugins/claudecode.lua`       | integração Claude Code ↔ tmux (detalhes abaixo)                |
| `lua/plugins/lsp.lua`, `sql.lua`   | `sqls`, inlay hints desligados, sqlfluff lendo o `.sqlfluff`   |
| `lua/plugins/colorscheme.lua`      | catppuccin-mocha                                               |
| `lua/plugins/vim-tmux-navigator.lua` | `<C-h/j/k/l>` navegam entre splits do nvim e panes do tmux   |
| `claude/commands/`                 | slash commands do Claude (`/testar`, `/corrigir`, `/explicar`) |
| `lazyvim.json`                     | extras do LazyVim habilitados (linguagens, yanky, dial…)       |

## Claude Code no tmux

O [claudecode.nvim](https://github.com/coder/claudecode.nvim) abre um servidor WebSocket no nvim
para o Claude ver seleções, receber `@menções` e propor alterações como diffs. Aqui ele usa um
*terminal provider* próprio: em vez de um terminal dentro do nvim, o Claude roda num **pane do tmux**.

Como o Claude é encontrado, em ordem:

1. o processo `claude` **conectado** à porta deste nvim, em qualquer janela ou sessão do tmux
   (descoberto via `ss` e a árvore de processos; vale também para um Claude aberto à mão que rodou
   `/ide`);
2. um pane desta janela criado por este nvim que ainda está subindo;
3. nenhum: cria um split ao lado (38% da largura) ou, com `<leader>aw`, uma janela nova.

Qualquer envio (`<leader>as`, `<leader>ab`, `<a-a>` no picker…) sem Claude aberto cria o pane e
entrega a menção quando ele conectar.

O ciclo de alteração não exige trocar de pane: quando o Claude propõe um diff, o foco vem para o
nvim (o diff abre numa aba própria); depois de `<leader>aa`/`<leader>ad`, o foco volta ao Claude.

### Atalhos

| Atalho                  | Ação                                                                      |
| ----------------------- | ------------------------------------------------------------------------- |
| `<leader>af`            | abrir/focar o Claude (cria um split se não houver)                        |
| `<leader>aw`            | abrir o Claude numa janela tmux própria                                   |
| `<leader>am`            | escolher modelo (com Claude aberto, manda `/model` na sessão atual)       |
| `<leader>ar` / `<leader>aC` | novo Claude com `--resume` / `--continue` (com um aberto, use `/resume` nele) |
| `<leader>ab`            | adicionar o buffer atual como `@menção`                                   |
| `<leader>as` (visual)   | enviar a seleção                                                          |
| `<leader>as` (árvore)   | adicionar o arquivo sob o cursor (neo-tree, oil, snacks explorer…)        |
| `<a-a>` (picker snacks) | adicionar os itens selecionados do picker                                 |
| `<leader>ap`            | digitar um prompt livre e enviar                                          |
| `<leader>at`            | `/testar <arquivo>`: roda os testes do pacote e corrige falhas            |
| `<leader>ae`            | `/corrigir <arquivo:linha> <diagnóstico>` ou `/explicar <arquivo:linha>`  |
| `<leader>aa` / `<leader>ad` | aceitar / rejeitar o diff                                             |
| `<leader>aD`            | fechar diffs pendentes                                                    |
| `<leader>ai`            | status da conexão                                                         |

`<leader>ap`, `<leader>at`, `<leader>ae` e `<leader>am` digitam no prompt do Claude via
`tmux send-keys`: se houver um rascunho escrito lá, o texto é colado no fim dele.

### Slash commands

Os prompts dos atalhos ficam em `claude/commands/*.md`, não no Lua. Assim funcionam também no Claude
fora do nvim e podem ser editados sem mexer na config. O `/testar` descobre sozinho o comando de
teste do projeto (Makefile, package.json, go.mod, Cargo.toml…).

### Ajustes

No topo de `lua/plugins/claudecode.lua`:

- `AUTO_START_ARGS`: flags de um Claude criado sem flags explícitas (`""` = sessão nova,
  `"--continue"` = retoma a última conversa do projeto);
- `SPLIT_SIZE`: largura do split (padrão `38%`).
