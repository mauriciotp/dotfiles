-- Claude Code num pane tmux, integrado ao nvim por um "terminal provider" customizado.
--
-- Como o Claude é encontrado (em ordem):
--   1. O processo `claude` CONECTADO à porta deste nvim, em qualquer janela/sessão tmux
--      (descoberto via `ss` + árvore de processos — funciona também para Claudes
--      abertos à mão que rodaram /ide).
--   2. Um pane desta janela criado por este nvim que ainda está subindo (@claude_port).
--   3. Nenhum: cria um pane ao lado (ou uma janela nova, com <leader>aw).
--
-- Como o plugin chama o provider em TODO envio (ClaudeCodeSend/Add/TreeAdd, picker),
-- enviar uma seleção sem Claude aberto cria o pane e a menção é entregue ao conectar.
-- Fora do tmux, cai no terminal do snacks (comportamento padrão do plugin).

-- Flags usadas quando o Claude é criado sem flags explícitas (envio, <leader>af, <leader>aw).
-- "" = sessão nova (recomendado); "--continue" = retoma a última conversa do projeto.
local AUTO_START_ARGS = ""
local SPLIT_SIZE = "38%"

local function tmux(args)
  local out = vim.fn.system(vim.list_extend({ "tmux" }, args))
  return vim.v.shell_error == 0 and vim.trim(out) or nil
end

local function server_port()
  local ok, claudecode = pcall(require, "claudecode")
  return ok and claudecode.state.port or nil
end

local function is_connected()
  local ok, claudecode = pcall(require, "claudecode")
  return ok and claudecode.is_claude_connected()
end

local function parent_pid(pid)
  local f = io.open("/proc/" .. pid .. "/stat")
  if not f then
    return nil
  end
  local stat = f:read("*a")
  f:close()
  -- o nome do processo vem entre parênteses e pode ter espaços: pega o que vem depois do último ")"
  return tonumber(stat:match("^.*%)%s+%S+%s+(%d+)"))
end

-- Pane cujo processo `claude` está conectado ao servidor WebSocket deste nvim
local function connected_pane()
  local port = server_port()
  if not port then
    return nil
  end
  local out = vim.fn.system({ "ss", "-tnpH", "state", "established", "( dport = :" .. port .. " )" })
  if vim.v.shell_error ~= 0 then
    return nil
  end

  local panes = {}
  for line in (tmux({ "list-panes", "-a", "-F", "#{pane_pid} #{pane_id}" }) or ""):gmatch("[^\n]+") do
    local ppid, id = line:match("^(%d+) (%S+)$")
    panes[tonumber(ppid)] = id
  end

  for pid in out:gmatch("pid=(%d+)") do
    pid = tonumber(pid)
    -- sobe na árvore de processos até achar o processo raiz de algum pane
    while pid and pid > 1 do
      if panes[pid] then
        return panes[pid]
      end
      pid = parent_pid(pid)
    end
  end
end

-- Pane desta janela que é um Claude: { id, ours = criado por este nvim }
local function window_pane()
  local port = tostring(server_port() or "")
  local fmt = "#{pane_id}\t#{@claude_port}\t#{pane_current_command}"
  local out = tmux({ "list-panes", "-t", vim.env.TMUX_PANE, "-F", fmt })
  local other
  for line in (out or ""):gmatch("[^\n]+") do
    local id, pane_port, cmd = line:match("^([^\t]*)\t([^\t]*)\t([^\t]*)$")
    if pane_port ~= "" and pane_port == port then
      return { id = id, ours = true }
    end
    -- @claude_port de outra porta = Claude de outro nvim nesta janela: não é nosso
    if cmd == "claude" and pane_port == "" and not other then
      other = { id = id, ours = false }
    end
  end
  return other
end

-- Resolve o Claude a usar: { id, connected, ours } ou nil
local function find_claude()
  local id = connected_pane()
  if id then
    return { id = id, connected = true, ours = true }
  end
  local pane = window_pane()
  if pane then
    pane.connected = false
    return pane
  end
end

-- Leva o foco do tmux até o pane, trocando de sessão/janela se preciso
local function focus_pane(id)
  local session = tmux({ "display-message", "-p", "-t", id, "#{session_id}" })
  local current = tmux({ "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{session_id}" })
  if session and session ~= current then
    tmux({ "switch-client", "-t", session })
  end
  tmux({ "select-window", "-t", id })
  tmux({ "select-pane", "-t", id })
end

-- Cria o Claude num split ao lado do nvim ("split") ou numa janela nova ("window")
local function create_pane(cmd_string, env, focus, where)
  local cmd
  if where == "window" then
    -- new-window não aceita pane como alvo: usa a janela do nvim, criando logo depois dela (-a)
    local window = tmux({ "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{window_id}" })
    cmd = { "new-window", "-a", "-n", "claude", "-t", window }
  else
    cmd = { "split-window", "-h", "-l", SPLIT_SIZE, "-t", vim.env.TMUX_PANE }
  end
  vim.list_extend(cmd, { "-P", "-F", "#{pane_id}", "-c", vim.fn.getcwd() })
  if focus == false then
    table.insert(cmd, 2, "-d")
  end
  for key, value in pairs(env or {}) do
    vim.list_extend(cmd, { "-e", key .. "=" .. value })
  end
  table.insert(cmd, cmd_string)

  local id = tmux(cmd)
  if id then
    tmux({ "set-option", "-p", "-t", id, "@claude", "1" })
    tmux({ "set-option", "-p", "-t", id, "@claude_port", tostring(server_port() or "") })
  else
    vim.notify("Falha ao criar o pane do Claude no tmux", vim.log.levels.ERROR)
  end
  return id
end

-- Onde o próximo Claude criado vai abrir; <leader>aw troca para "window" por uma chamada
local next_where = "split"

-- Abre/foca o Claude; usado por todos os comandos do plugin
local function open(cmd_string, env, _, focus)
  local where = next_where
  next_where = "split"
  local claude = find_claude()
  if not claude then
    -- criado sem flags explícitas (envio, <leader>af, <leader>aw)? usa as flags automáticas
    if not cmd_string:find("%-%-") and AUTO_START_ARGS ~= "" then
      cmd_string = cmd_string .. " " .. AUTO_START_ARGS
    end
    create_pane(cmd_string, env, focus, where)
    return
  end

  local model = cmd_string:match("%-%-model[= ](%S+)")
  if model then
    -- ClaudeCodeSelectModel com Claude já aberto: troca o modelo na sessão atual
    tmux({ "send-keys", "-t", claude.id, "-l", "/model " .. model })
    tmux({ "send-keys", "-t", claude.id, "Enter" })
  elseif cmd_string:find("%-%-") then
    vim.notify("Já existe um Claude para este nvim; use /resume dentro dele", vim.log.levels.INFO)
  elseif not claude.ours then
    vim.notify("O Claude deste pane não está conectado ao nvim: rode /ide nele", vim.log.levels.WARN)
  end
  if focus ~= false then
    focus_pane(claude.id)
  end
end

---@type ClaudeCodeTerminalProvider
local tmux_provider = {
  setup = function() end,
  is_available = function()
    return vim.env.TMUX ~= nil
  end,
  open = open,
  simple_toggle = function(cmd_string, env, config)
    open(cmd_string, env, config, true)
  end,
  focus_toggle = function(cmd_string, env, config)
    open(cmd_string, env, config, true)
  end,
  -- só fecha panes criados por este nvim; um Claude em outra janela é seu
  close = function()
    local claude = find_claude()
    if claude and claude.ours then
      tmux({ "kill-pane", "-t", claude.id })
    end
  end,
  ensure_visible = function() end,
  get_active_bufnr = function()
    return nil
  end,
}

-- Espera o Claude conectar (até `timeout` ms) e chama `fn`
local function when_connected(fn, timeout)
  local was_connected = is_connected()
  local waited = 0
  local timer = vim.uv.new_timer()
  timer:start(
    0,
    250,
    vim.schedule_wrap(function()
      waited = waited + 250
      if is_connected() or waited >= timeout then
        timer:stop()
        timer:close()
        -- Claude acabou de conectar: margem para a TUI ficar pronta e as menções
        -- na fila caírem no prompt antes do texto. Já conectado: envia na hora.
        vim.defer_fn(fn, (is_connected() and not was_connected) and 1000 or 0)
      end
    end)
  )
end

-- Digita `text` no prompt do Claude e envia; cria o Claude se não existir
local function send_text(text)
  if not vim.env.TMUX then
    require("claudecode.terminal").send_to_terminal(text)
    return
  end
  text = text:gsub("\n", " ")

  local function type_into(claude)
    tmux({ "send-keys", "-t", claude.id, "-l", text })
    tmux({ "send-keys", "-t", claude.id, "Enter" })
    focus_pane(claude.id)
  end

  local claude = find_claude()
  if claude and not claude.ours then
    -- Claude aberto à mão e sem /ide: nunca vai conectar, então não adianta esperar
    vim.notify("O Claude deste pane não está conectado ao nvim: rode /ide nele", vim.log.levels.WARN)
    return type_into(claude)
  end
  if not claude then
    vim.cmd("ClaudeCodeFocus")
  end
  when_connected(function()
    claude = find_claude()
    if not claude then
      vim.notify("Claude não encontrado", vim.log.levels.WARN)
      return
    end
    type_into(claude)
  end, 20000)
end

-- Caminho do buffer atual relativo ao cwd (vazio se o buffer não tem arquivo)
local function current_file()
  local file = vim.fn.expand("%:p")
  return file ~= "" and vim.fn.fnamemodify(file, ":.") or ""
end

return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal = {
        -- fora do tmux, usa o terminal padrão do plugin (snacks)
        provider = vim.env.TMUX and tmux_provider or "snacks",
      },
      -- após um envio, o plugin chama provider.open() -> foca o pane do Claude
      focus_after_send = true,
      -- tempo para o Claude subir e conectar antes de descartar menções na fila
      connection_timeout = 20000,
      queue_timeout = 20000,
      diff_opts = {
        layout = "vertical",
        open_in_new_tab = true, -- diff ocupa a tela inteira; o Claude está no pane tmux
      },
    },
    init = function()
      -- Quando o Claude propõe uma alteração, traz o foco para este nvim
      -- (útil quando o Claude está em outra janela tmux)
      vim.api.nvim_create_autocmd("User", {
        pattern = "ClaudeCodeDiffOpened",
        callback = function()
          if vim.env.TMUX then
            focus_pane(vim.env.TMUX_PANE)
          end
        end,
      })
      -- Depois de aceitar/rejeitar, devolve o foco ao Claude para seguir a conversa.
      -- "replaced"/"setup failed" não contam: outro diff está abrindo ou nada abriu.
      vim.api.nvim_create_autocmd("User", {
        pattern = "ClaudeCodeDiffClosed",
        callback = function(ev)
          local reason = (ev.data or {}).reason or ""
          if not vim.env.TMUX or reason:find("replaced") or reason:find("setup failed") then
            return
          end
          -- espera o plugin fechar a aba do diff antes de trocar de pane
          vim.defer_fn(function()
            local claude = find_claude()
            if claude then
              focus_pane(claude.id)
            end
          end, 100)
        end,
      })
    end,
    keys = {
      { "<leader>a", "", desc = "+ai (claude)", mode = { "n", "v" } },
      { "<leader>ac", false }, -- remove o mapeamento do extra do LazyVim
      { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Claude: abrir/focar" },
      { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Claude: escolher modelo" },
      { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Claude: escolher conversa (novo)" },
      { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Claude: continuar última (novo)" },
      {
        "<leader>aw",
        function()
          if not vim.env.TMUX then
            return vim.notify("Fora do tmux", vim.log.levels.WARN)
          end
          local claude = find_claude()
          if claude then
            return focus_pane(claude.id)
          end
          -- passa pelo plugin para ele montar o comando e o env (porta, no_proxy, terminal_cmd)
          next_where = "window"
          vim.cmd("ClaudeCodeOpen")
        end,
        desc = "Claude: abrir em janela tmux própria",
      },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Claude: adicionar buffer" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Claude: enviar seleção" },
      {
        "<leader>as",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Claude: adicionar arquivo",
        ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw", "snacks_picker_list" },
      },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Claude: aceitar diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Claude: rejeitar diff" },
      { "<leader>aD", "<cmd>ClaudeCodeCloseAllDiffs<cr>", desc = "Claude: fechar diffs pendentes" },
      { "<leader>ai", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude: status" },
      {
        "<leader>ap",
        function()
          vim.ui.input({ prompt = "Claude: " }, function(input)
            if input and input ~= "" then
              send_text(input)
            end
          end)
        end,
        desc = "Claude: prompt livre",
      },
      -- Os prompts ficam em slash commands do Claude (claude/commands/ neste repo,
      -- linkados em ~/.claude/commands/): o atalho só manda o comando com o arquivo.
      {
        "<leader>at",
        function()
          send_text(vim.trim("/testar " .. current_file()))
        end,
        desc = "Claude: testar e corrigir pacote",
      },
      {
        "<leader>ae",
        function()
          local lnum = vim.api.nvim_win_get_cursor(0)[1]
          local msgs = vim.tbl_map(function(d)
            return d.message
          end, vim.diagnostic.get(0, { lnum = lnum - 1 }))
          local where = current_file() .. ":" .. lnum
          if #msgs > 0 then
            send_text("/corrigir " .. where .. " " .. table.concat(msgs, " | "))
          else
            send_text("/explicar " .. where)
          end
        end,
        desc = "Claude: explicar/corrigir diagnóstico da linha",
      },
    },
  },

  -- Alt+a dentro de um picker do snacks (files/grep/buffers) adiciona os itens ao Claude
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          claude_send = function(picker)
            local items = picker:selected({ fallback = true })
            picker:close()
            for _, item in ipairs(items) do
              if item.file then
                require("claudecode").send_at_mention(Snacks.picker.util.path(item), nil, nil, "snacks_picker")
              end
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "claude_send", mode = { "n", "i" }, desc = "Enviar ao Claude" },
            },
          },
        },
      },
    },
  },
}
