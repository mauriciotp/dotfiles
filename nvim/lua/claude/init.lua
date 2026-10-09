-- Integração do Claude Code no nvim, em cima do claudecode.nvim.
--
-- O plugin cuida do protocolo (servidor WebSocket, menções, diffs). Este módulo
-- acrescenta, no mesmo padrão de comandos :ClaudeCode* do plugin:
--
--   :ClaudeCodeAsk [texto]      pergunta livre com placeholders (@this, @buffer…)
--   :ClaudeCodeSelect           menu com tudo: prompts, slash commands e ações
--   :ClaudeCodeCommand [nome]   escolhe e envia um slash command do Claude
--   :ClaudeCodeOpenWindow       abre o Claude numa janela tmux própria
--   :ClaudeCode<Prompt>         um comando por prompt de claude/prompts.lua
--
-- Todos os comandos que agem sobre código aceitam range (seleção ou :10,20).
-- Os atalhos são gerados por M.keys() a partir das tabelas abaixo e de prompts.lua,
-- para que comandos, atalhos, which-key e o Select nunca fiquem dessincronizados.
--
-- Módulos:
--   claude/prompts.lua  registro central dos prompts prontos
--   claude/context.lua  placeholders (@this, @diagnostics…)
--   claude/tmux.lua     Claude num pane do tmux (provider + transporte)

local context = require("claude.context")
local prompts = require("claude.prompts")
local tmux = require("claude.tmux")

local M = {}

-- ---------------------------------------------------------------------------
-- Conexão
-- ---------------------------------------------------------------------------

function M.is_connected()
  local ok, claudecode = pcall(require, "claudecode")
  return ok and claudecode.is_claude_connected()
end

-- Espera o Claude conectar (até `timeout` ms) e chama `fn`
function M.when_connected(fn, timeout)
  local was_connected = M.is_connected()
  local waited = 0
  local timer = vim.uv.new_timer()
  timer:start(
    0,
    250,
    vim.schedule_wrap(function()
      waited = waited + 250
      if M.is_connected() or waited >= timeout then
        timer:stop()
        timer:close()
        -- Claude acabou de conectar: margem para a TUI ficar pronta e as menções
        -- na fila caírem no prompt antes do texto. Já conectado: envia na hora.
        vim.defer_fn(fn, (M.is_connected() and not was_connected) and 1000 or 0)
      end
    end)
  )
end

-- ---------------------------------------------------------------------------
-- Envio
-- ---------------------------------------------------------------------------

-- Cola `text` no prompt do Claude e envia (submit = false só cola); cria o Claude
-- se não existir e espera ele conectar.
function M.send(text, submit)
  if not vim.env.TMUX then
    -- terminal do snacks: send_to_terminal também usa bracketed paste
    local terminal = require("claudecode.terminal")
    if not terminal.get_active_terminal_bufnr() then
      vim.cmd("ClaudeCodeFocus")
    end
    M.when_connected(function()
      terminal.send_to_terminal(text, { submit = submit ~= false, focus = true })
    end, 20000)
    return
  end

  local function deliver(claude)
    tmux.paste(claude.id, text, submit)
    tmux.focus(claude.id)
  end

  local claude = tmux.find()
  if claude and not claude.connected and not claude.ours then
    -- Claude aberto à mão e sem /ide: nunca vai conectar, então não adianta esperar
    vim.notify("O Claude deste pane não está conectado ao nvim: rode /ide nele", vim.log.levels.WARN)
    return deliver(claude)
  end
  if not claude then
    vim.cmd("ClaudeCodeFocus")
  end
  M.when_connected(function()
    claude = tmux.find()
    if not claude then
      return vim.notify("Claude não encontrado", vim.log.levels.WARN)
    end
    deliver(claude)
  end, 20000)
end

-- Expande os placeholders de `text` com o contexto `ctx` e envia
---@param ctx claude.Context
function M.prompt(text, ctx, submit)
  local expanded, err = context.expand(text, ctx)
  if not expanded then
    return vim.notify(err, vim.log.levels.WARN, { title = "Claude" })
  end
  M.send(expanded, submit)
end

-- ---------------------------------------------------------------------------
-- Ask e slash commands
-- ---------------------------------------------------------------------------

-- Abre um input já preenchido com `default` (histórico com <Up>/<Down>) e envia
---@param ctx claude.Context
function M.ask(ctx, default)
  vim.ui.input({
    prompt = "Ask Claude",
    default = default or "@this: ",
    -- snacks.input: <Tab> completa a última palavra (getcompletion com este tipo)
    completion = "customlist,v:lua.require'claude.context'.complete",
  }, function(input)
    if input and vim.trim(input) ~= "" then
      M.prompt(input, ctx)
    end
  end)
end

-- Comandos nativos do Claude Code mais úteis a partir do editor (args = abre o input)
local builtin_commands = {
  { name = "clear", desc = "Limpa a conversa" },
  { name = "compact", desc = "Compacta a conversa (instruções opcionais)", args = true },
  { name = "context", desc = "Mostra o uso da janela de contexto" },
  { name = "init", desc = "Cria o CLAUDE.md do projeto" },
  { name = "memory", desc = "Edita os arquivos de memória" },
  { name = "resume", desc = "Retoma uma conversa anterior" },
  { name = "rewind", desc = "Volta a conversa/código a um ponto anterior" },
  { name = "review", desc = "Revisa um pull request" },
  { name = "status", desc = "Status da sessão" },
  { name = "usage", desc = "Uso do plano" },
}

-- Lê description/argument-hint do frontmatter de um .md
local function frontmatter(file)
  local meta, inside = {}, false
  for line in io.lines(file) do
    if line == "---" then
      if inside then
        break
      end
      inside = true
    elseif inside then
      local key, value = line:match("^([%w%-]+):%s*(.-)%s*$")
      if key then
        meta[key] = value
      end
    else
      break -- sem frontmatter
    end
  end
  return meta
end

-- Slash commands do usuário e do projeto (commands/*.md e skills/*/SKILL.md) + nativos
local function slash_commands()
  local list, seen = {}, {}
  local function add(name, meta, source)
    if not seen[name] then
      seen[name] = true
      table.insert(list, {
        name = name,
        desc = meta.description or "",
        args = meta["argument-hint"] ~= nil,
        source = source,
      })
    end
  end
  -- projeto primeiro: no Claude, um comando do projeto tem precedência
  for _, dir in ipairs({ { ".claude", "project" }, { vim.fn.expand("~/.claude"), "user" } }) do
    for _, file in ipairs(vim.fn.glob(dir[1] .. "/commands/**/*.md", false, true)) do
      local rel = file:sub(#dir[1] + #"/commands/" + 1, -4)
      -- subpasta vira namespace, como no Claude: commands/git/pr.md -> /git:pr
      add((rel:gsub("/", ":")), frontmatter(file), dir[2])
    end
    for _, file in ipairs(vim.fn.glob(dir[1] .. "/skills/*/SKILL.md", false, true)) do
      local meta = frontmatter(file)
      add(meta.name or vim.fn.fnamemodify(file, ":h:t"), meta, dir[2])
    end
  end
  for _, cmd in ipairs(builtin_commands) do
    add(cmd.name, { description = cmd.desc, ["argument-hint"] = cmd.args and "" or nil }, "builtin")
  end
  return list
end

-- Envia o slash command `name`; se ele recebe argumentos, abre o input para completá-los
---@param ctx claude.Context
function M.command(name, ctx)
  local function run(cmd)
    if cmd.args then
      M.ask(ctx, "/" .. cmd.name .. " ")
    else
      M.send("/" .. cmd.name)
    end
  end
  local list = slash_commands()
  if name and name ~= "" then
    name = name:gsub("^/", "")
    for _, cmd in ipairs(list) do
      if cmd.name == name then
        return run(cmd)
      end
    end
    return run({ name = name })
  end
  vim.ui.select(list, {
    prompt = "Claude Slash Commands",
    format_item = function(cmd)
      return ("%-22s %-8s %s"):format("/" .. cmd.name, cmd.source, cmd.desc)
    end,
  }, function(cmd)
    if cmd then
      run(cmd)
    end
  end)
end

-- ---------------------------------------------------------------------------
-- Operador ga: anexa um trecho como menção (ga{motion}, gaa = linha, . repete)
-- ---------------------------------------------------------------------------

function M.opfunc()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    return vim.notify("Buffer sem arquivo", vim.log.levels.WARN, { title = "Claude" })
  end
  local l1 = vim.api.nvim_buf_get_mark(0, "[")[1]
  local l2 = vim.api.nvim_buf_get_mark(0, "]")[1]
  vim.cmd(("ClaudeCodeAdd %s %d %d"):format(vim.fn.fnameescape(file), l1, l2))
end

function M.operator()
  vim.o.operatorfunc = "v:lua.require'claude'.opfunc"
  return "g@"
end

-- ---------------------------------------------------------------------------
-- Ações e atalhos (fonte única para comandos, which-key e o Select)
-- ---------------------------------------------------------------------------

local trees = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" }

-- Ações fixas. `range` = age sobre código (atalho também no visual, com a seleção).
-- `select = false` = fica fora do :ClaudeCodeSelect.
---@type { key?: string, cmd: string, desc: string, range?: boolean, ft?: string[], select?: boolean }[]
local actions = {
  -- Interação
  { key = "<leader>aa", cmd = "ClaudeCodeAsk", desc = "Ask Claude", range = true },
  { key = "<leader>as", cmd = "ClaudeCodeSelect", desc = "Select Claude Action", range = true, select = false },
  { key = "<leader>a/", cmd = "ClaudeCodeCommand", desc = "Slash Commands", range = true },
  -- Sessão
  { key = "<leader>ac", cmd = "ClaudeCodeFocus", desc = "Focus Claude" },
  { key = "<leader>aw", cmd = "ClaudeCodeOpenWindow", desc = "Open Claude in tmux Window" },
  { key = "<leader>am", cmd = "ClaudeCodeSelectModel", desc = "Select Claude Model" },
  -- Contexto
  { key = "<leader>ab", cmd = "ClaudeCodeAdd %", desc = "Add Current Buffer" },
  { key = "<leader>ab", cmd = "ClaudeCodeTreeAdd", desc = "Add File", ft = trees, select = false },
  -- Diff
  { key = "<leader>ay", cmd = "ClaudeCodeDiffAccept", desc = "Accept Diff" },
  { key = "<leader>an", cmd = "ClaudeCodeDiffDeny", desc = "Deny Diff" },
  { key = "<leader>aD", cmd = "ClaudeCodeCloseAllDiffs", desc = "Close Pending Diffs" },
  -- Info (só no Select; a conexão aparece na statusline)
  { cmd = "ClaudeCodeStatus", desc = "Claude Status" },
}

-- Um item por prompt de prompts.lua + as ações (prompts primeiro: são o mais usado no Select)
local function all_actions()
  local list = {}
  for _, p in ipairs(prompts) do
    table.insert(list, { key = p.key, cmd = "ClaudeCode" .. p.name, desc = p.desc, range = true, prompt = p })
  end
  return vim.list_extend(list, actions)
end

-- Especificação de atalhos para o lazy.nvim
function M.keys()
  local keys = {
    { "<leader>a", "", desc = "+ai", mode = { "n", "x" } },
    { "ga", M.operator, expr = true, desc = "Add Range to Claude" },
    {
      "gaa",
      function()
        return M.operator() .. "_"
      end,
      expr = true,
      desc = "Add Line to Claude",
    },
    { "ga", "<cmd>ClaudeCodeSend<cr>", mode = "x", desc = "Add Selection to Claude" },
  }
  for _, a in ipairs(all_actions()) do
    if a.key then
      -- ":" no visual preenche '<,'> e o comando recebe a seleção como range
      local rhs = a.range and (":" .. a.cmd .. "<cr>") or ("<cmd>" .. a.cmd .. "<cr>")
      table.insert(keys, {
        a.key,
        rhs,
        desc = a.desc,
        mode = a.range and { "n", "x" } or "n",
        ft = a.ft,
        silent = true,
      })
    end
  end
  return keys
end

-- Menu com tudo; executa o comando com o mesmo range de quem chamou
---@param opts table opts do user command
function M.select(opts)
  local items = vim.tbl_filter(function(a)
    return a.select ~= false
  end, all_actions())
  vim.ui.select(items, {
    prompt = "Claude",
    format_item = function(a)
      local kind = a.prompt and "Prompt" or "Action"
      return ("%-7s %-28s %s"):format(kind, a.desc, a.key or "")
    end,
  }, function(a)
    if a then
      local range = (a.range and opts.range > 0) and (opts.line1 .. "," .. opts.line2) or ""
      vim.cmd(range .. a.cmd)
    end
  end)
end

-- ---------------------------------------------------------------------------
-- Statusline (lualine): ícone do Claude, colorido quando conectado a este nvim
-- ---------------------------------------------------------------------------

M.statusline = {
  function()
    return "󰚩"
  end,
  cond = function()
    return package.loaded.claudecode ~= nil
  end,
  color = function()
    return { fg = Snacks.util.color(M.is_connected() and "Special" or "Comment") }
  end,
}

-- ---------------------------------------------------------------------------
-- Setup: comandos e autocmds (chamado depois do setup do claudecode.nvim)
-- ---------------------------------------------------------------------------

local function create_commands()
  local cmd = vim.api.nvim_create_user_command

  cmd("ClaudeCodeAsk", function(opts)
    local ctx = context.capture(opts)
    if opts.args ~= "" then
      M.prompt(opts.args, ctx)
    else
      M.ask(ctx)
    end
  end, {
    range = true,
    nargs = "*",
    desc = "Ask Claude (placeholders: @this, @buffer, @diagnostics…)",
    complete = context.complete,
  })

  cmd("ClaudeCodeSelect", M.select, { range = true, desc = "Select a Claude prompt or action" })

  cmd("ClaudeCodeCommand", function(opts)
    M.command(opts.args, context.capture(opts))
  end, {
    range = true,
    nargs = "?",
    desc = "Send a Claude slash command",
    complete = function()
      return vim.tbl_map(function(c)
        return c.name
      end, slash_commands())
    end,
  })

  cmd("ClaudeCodeOpenWindow", function()
    if not vim.env.TMUX then
      return vim.notify("Fora do tmux", vim.log.levels.WARN)
    end
    tmux.open_window()
  end, { desc = "Open Claude in its own tmux window" })

  for _, p in ipairs(prompts) do
    cmd("ClaudeCode" .. p.name, function(opts)
      M.prompt(p.prompt, context.capture(opts))
    end, { range = true, desc = p.desc })
  end
end

local function create_autocmds()
  local group = vim.api.nvim_create_augroup("claude", { clear = true })

  -- Quando o Claude propõe uma alteração, traz o foco para este nvim
  -- (útil quando o Claude está em outra janela tmux)
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ClaudeCodeDiffOpened",
    callback = function()
      if vim.env.TMUX then
        tmux.focus_self()
      end
    end,
  })

  -- Depois de aceitar/rejeitar, recarrega os buffers e devolve o foco ao Claude.
  -- Só esses motivos contam ("diff tab closed after save/reject", "diff rejected
  -- (keep_empty)"): <leader>aD, :ClaudeCodeStop e o Claude fechando as abas não.
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "ClaudeCodeDiffClosed",
    callback = function(ev)
      local reason = (ev.data or {}).reason or ""
      if not (reason:find("after save") or reason:find("reject")) then
        return
      end
      -- espera o plugin fechar a aba do diff antes de trocar de pane
      vim.defer_fn(function()
        vim.cmd("silent! checktime")
        local claude = vim.env.TMUX and tmux.find()
        if claude then
          tmux.focus(claude.id)
        end
      end, 100)
    end,
  })

  -- Recarrega em tempo real arquivos que o Claude gravou direto (modo auto-accept),
  -- com o nvim visível ao lado. Só com o Claude conectado e em modo normal.
  local timer = vim.uv.new_timer()
  timer:start(
    1000,
    1000,
    vim.schedule_wrap(function()
      if M.is_connected() and vim.api.nvim_get_mode().mode == "n" and vim.fn.getcmdwintype() == "" then
        vim.cmd("silent! checktime")
      end
    end)
  )
  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      timer:stop()
      timer:close()
    end,
  })
end

function M.setup()
  create_commands()
  create_autocmds()
end

return M
