-- Claude Code num pane do tmux: "terminal provider" do claudecode.nvim e transporte de texto.
--
-- Como o Claude é encontrado (em ordem):
--   1. O processo `claude` CONECTADO à porta deste nvim, em qualquer janela/sessão tmux
--      (descoberto via `ss` + árvore de processos — funciona também para Claudes
--      abertos à mão que rodaram /ide).
--   2. Um pane desta janela criado por este nvim que ainda está subindo (@claude_port).
--   3. Nenhum: cria um pane ao lado (ou uma janela nova, com :ClaudeCodeOpenWindow).
--
-- Como o plugin chama o provider em TODO envio (ClaudeCodeSend/Add/TreeAdd, picker),
-- enviar uma seleção sem Claude aberto cria o pane e a menção é entregue ao conectar.

local M = {}

-- Flags usadas quando o Claude é criado sem flags explícitas (envio, :ClaudeCodeFocus…).
-- "" = sessão nova (recomendado); "--continue" = retoma a última conversa do projeto.
M.AUTO_START_ARGS = ""
-- Largura do split criado ao lado do nvim
M.SPLIT_SIZE = "38%"

local function tmux(args, input)
  local out = vim.fn.system(vim.list_extend({ "tmux" }, args), input)
  return vim.v.shell_error == 0 and vim.trim(out) or nil
end

local function server_port()
  local ok, claudecode = pcall(require, "claudecode")
  return ok and claudecode.state.port or nil
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

-- Pane cujo processo `claude` está conectado ao servidor WebSocket deste nvim.
-- Retorna o id e se o pane foi criado por este nvim (@claude_port igual à nossa porta).
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
  -- @claude_port no meio: vazio no fim da última linha seria comido pelo trim do tmux()
  local fmt = "#{pane_pid}\t#{@claude_port}\t#{pane_id}"
  for line in (tmux({ "list-panes", "-a", "-F", fmt }) or ""):gmatch("[^\n]+") do
    local ppid, pane_port, id = line:match("^(%d+)\t([^\t]*)\t([^\t]+)$")
    if ppid then
      panes[tonumber(ppid)] = { id = id, ours = pane_port == tostring(port) }
    end
  end

  for pid in out:gmatch("pid=(%d+)") do
    pid = tonumber(pid)
    -- sobe na árvore de processos até achar o processo raiz de algum pane
    while pid and pid > 1 do
      if panes[pid] then
        return panes[pid].id, panes[pid].ours
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

-- Resolve o Claude a usar: { id, connected, ours } ou nil.
-- ours = pane criado por este nvim; connected = conectado ao servidor deste nvim.
-- Um Claude aberto à mão que rodou /ide é connected mas não ours.
function M.find()
  local id, ours = connected_pane()
  if id then
    return { id = id, connected = true, ours = ours }
  end
  local pane = window_pane()
  if pane then
    pane.connected = false
    return pane
  end
end

-- Leva o foco do tmux até o pane, trocando de sessão/janela se preciso
function M.focus(id)
  local session = tmux({ "display-message", "-p", "-t", id, "#{session_id}" })
  local current = tmux({ "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{session_id}" })
  if session and session ~= current then
    tmux({ "switch-client", "-t", session })
  end
  tmux({ "select-window", "-t", id })
  tmux({ "select-pane", "-t", id })
end

-- Foca o pane deste nvim (usado quando o Claude abre um diff)
function M.focus_self()
  M.focus(vim.env.TMUX_PANE)
end

-- Cola `text` no prompt do Claude e, se `submit`, envia.
-- paste-buffer -p usa bracketed paste: quebras de linha chegam como texto, não como Enter.
-- Se houver um rascunho no prompt do Claude, o texto é colado no fim dele.
function M.paste(id, text, submit)
  tmux({ "load-buffer", "-b", "claude-nvim", "-" }, text)
  tmux({ "paste-buffer", "-p", "-d", "-b", "claude-nvim", "-t", id })
  if submit ~= false then
    -- margem para a TUI terminar de processar a colagem antes do Enter
    vim.defer_fn(function()
      tmux({ "send-keys", "-t", id, "Enter" })
    end, 150)
  end
end

-- Cria o Claude num split ao lado do nvim ("split") ou numa janela nova ("window")
local function create_pane(cmd_string, env, focus, where)
  local cmd
  if where == "window" then
    -- new-window não aceita pane como alvo: usa a janela do nvim, criando logo depois dela (-a)
    local window = tmux({ "display-message", "-p", "-t", vim.env.TMUX_PANE, "#{window_id}" })
    cmd = { "new-window", "-a", "-n", "claude", "-t", window }
  else
    cmd = { "split-window", "-h", "-l", M.SPLIT_SIZE, "-t", vim.env.TMUX_PANE }
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

-- Onde o próximo Claude criado vai abrir; :ClaudeCodeOpenWindow troca para "window" por uma chamada
local next_where = "split"

-- Abre/foca o Claude; usado por todos os comandos do plugin
local function open(cmd_string, env, _, focus)
  local where = next_where
  next_where = "split"
  local claude = M.find()
  if not claude then
    -- criado sem flags explícitas (envio, :ClaudeCodeFocus…)? usa as flags automáticas
    if not cmd_string:find("%-%-") and M.AUTO_START_ARGS ~= "" then
      cmd_string = cmd_string .. " " .. M.AUTO_START_ARGS
    end
    create_pane(cmd_string, env, focus, where)
    return
  end

  local model = cmd_string:match("%-%-model[= ](%S+)")
  if model then
    -- :ClaudeCodeSelectModel com Claude já aberto: troca o modelo na sessão atual
    -- (espera conectar: num pane recém-criado a TUI ainda não leria o comando)
    require("claude").when_connected(function()
      M.paste(claude.id, "/model " .. model)
    end, (claude.ours and not claude.connected) and 20000 or 0)
  elseif cmd_string:find("%-%-") then
    vim.notify("Já existe um Claude para este nvim; use /resume dentro dele", vim.log.levels.INFO)
  elseif not claude.connected and not claude.ours then
    vim.notify("O Claude deste pane não está conectado ao nvim: rode /ide nele", vim.log.levels.WARN)
  end
  if focus ~= false then
    M.focus(claude.id)
  end
end

-- Abre o Claude numa janela tmux própria (ou foca o que já existe)
function M.open_window()
  local claude = M.find()
  if claude then
    return M.focus(claude.id)
  end
  -- passa pelo plugin para ele montar o comando e o env (porta, no_proxy, terminal_cmd)
  next_where = "window"
  vim.cmd("ClaudeCodeOpen")
end

---@type ClaudeCodeTerminalProvider
M.provider = {
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
  -- só fecha panes criados por este nvim; um Claude aberto à mão (mesmo com /ide) é seu
  close = function()
    local claude = M.find()
    if claude and claude.ours then
      tmux({ "kill-pane", "-t", claude.id })
    end
  end,
  ensure_visible = function() end,
  get_active_bufnr = function()
    return nil
  end,
}

return M
