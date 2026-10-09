-- Placeholders de contexto: trocados no texto de um prompt antes do envio ao Claude.
--
--   @this         seleção/range, senão a linha do cursor  -> @arquivo#L10-20
--   @buffer       buffer atual                             -> @arquivo
--   @buffers      buffers abertos                          -> @a.go @b.go
--   @visible      linhas visíveis na janela                -> @arquivo#L30-75
--   @diagnostics  diagnósticos (WARN+) do range, senão do buffer, em texto
--   @quickfix     itens da lista quickfix, em texto
--   @marks        marks globais (A-Z)                      -> @arquivo#L12 …
--
-- Referências a arquivo usam a sintaxe de menção do Claude Code (@caminho#Linício-fim):
-- o Claude lê o trecho do DISCO, por isso os buffers citados são salvos antes do envio.
-- Só é trocado um @nome conhecido no início do texto ou após espaço; o resto fica intacto.

local M = {}

---@class claude.Context
---@field buf integer buffer de origem
---@field win integer janela de origem
---@field line1 integer primeira linha de @this (1-indexed)
---@field line2 integer última linha de @this
---@field range boolean se houve seleção/range explícito
---@field save table<integer, boolean> buffers a salvar antes do envio

-- Captura o contexto no momento do comando (antes de um input mudar a janela).
-- `opts` vem de nvim_create_user_command: range > 0 = seleção visual ou :{range}.
---@return claude.Context
function M.capture(opts)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local range = opts and opts.range and opts.range > 0
  return {
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
    line1 = range and opts.line1 or line,
    line2 = range and opts.line2 or line,
    range = range or false,
    save = {},
  }
end

-- Caminho relativo ao cwd ("" se o buffer não tem arquivo)
local function path(buf)
  local name = vim.api.nvim_buf_get_name(buf)
  return name ~= "" and vim.fn.fnamemodify(name, ":.") or ""
end

-- Menção no formato do Claude Code: @arquivo, @arquivo#L10 ou @arquivo#L10-20
local function mention(file, l1, l2)
  local ref = "@" .. file
  if l1 then
    ref = ref .. "#L" .. l1 .. ((l2 and l2 ~= l1) and ("-" .. l2) or "")
  end
  return ref
end

-- Buffer de arquivo de verdade (não terminal, picker, help…)
local function is_file_buf(buf)
  return vim.bo[buf].buftype == "" and vim.api.nvim_buf_get_name(buf) ~= ""
end

-- Cada placeholder recebe o contexto e devolve o texto ou nil + mensagem de erro
local placeholders = {}

function placeholders.this(ctx)
  if not is_file_buf(ctx.buf) then
    return nil, "Buffer sem arquivo"
  end
  ctx.save[ctx.buf] = true
  return mention(path(ctx.buf), ctx.line1, ctx.line2)
end

function placeholders.buffer(ctx)
  if not is_file_buf(ctx.buf) then
    return nil, "Buffer sem arquivo"
  end
  ctx.save[ctx.buf] = true
  return mention(path(ctx.buf))
end

function placeholders.buffers(ctx)
  local refs = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.bo[buf].buflisted and is_file_buf(buf) then
      ctx.save[buf] = true
      table.insert(refs, mention(path(buf)))
    end
  end
  if #refs == 0 then
    return nil, "Nenhum buffer com arquivo aberto"
  end
  return table.concat(refs, " ")
end

function placeholders.visible(ctx)
  if not is_file_buf(ctx.buf) then
    return nil, "Buffer sem arquivo"
  end
  ctx.save[ctx.buf] = true
  local top = vim.fn.line("w0", ctx.win)
  local bottom = vim.fn.line("w$", ctx.win)
  return mention(path(ctx.buf), top, bottom)
end

function placeholders.diagnostics(ctx)
  -- hints/info não são problemas a corrigir: só WARN e ERROR
  local diags = vim.diagnostic.get(ctx.buf, { severity = { min = vim.diagnostic.severity.WARN } })
  local file = path(ctx.buf)
  local lines, seen = {}, {}
  for _, d in ipairs(diags) do
    local lnum = d.lnum + 1
    if not ctx.range or (lnum >= ctx.line1 and lnum <= ctx.line2) then
      local item = ("%s:%d:%d: %s%s: %s"):format(
        file,
        lnum,
        d.col + 1,
        d.source and ("[" .. d.source .. "] ") or "",
        vim.diagnostic.severity[d.severity],
        (d.message:gsub("%s*\n%s*", " "))
      )
      if not seen[item] then
        seen[item] = true
        table.insert(lines, item)
      end
    end
  end
  if #lines == 0 then
    return nil, ctx.range and "Nenhum diagnóstico na seleção" or "Nenhum diagnóstico no buffer"
  end
  ctx.save[ctx.buf] = true
  return "\n" .. table.concat(lines, "\n") .. "\n"
end

function placeholders.quickfix()
  local lines = {}
  for _, item in ipairs(vim.fn.getqflist()) do
    local file = item.bufnr > 0 and path(item.bufnr) or ""
    local where = file ~= "" and (file .. ":" .. item.lnum .. ": ") or ""
    table.insert(lines, where .. vim.trim(item.text))
  end
  if #lines == 0 then
    return nil, "Lista quickfix vazia"
  end
  return "\n" .. table.concat(lines, "\n") .. "\n"
end

function placeholders.marks()
  local refs = {}
  for _, m in ipairs(vim.fn.getmarklist()) do
    if m.mark:match("^'[A-Z]$") and m.file then
      table.insert(refs, mention(vim.fn.fnamemodify(m.file, ":."), m.pos[2]))
    end
  end
  if #refs == 0 then
    return nil, "Nenhum mark global (A-Z)"
  end
  return table.concat(refs, " ")
end

-- Nomes dos placeholders, para documentação e realce
M.names = vim.tbl_keys(placeholders)
table.sort(M.names)

-- Completa um placeholder a partir do `arglead` ("@di" -> "@diagnostics"). Serve
-- como `complete` de user command e, via customlist, ao snacks.input do Ask.
function M.complete(arglead)
  if not arglead:match("^@%a*$") then
    return {}
  end
  local items = {}
  for _, name in ipairs(M.names) do
    if vim.startswith("@" .. name, arglead) then
      table.insert(items, "@" .. name)
    end
  end
  return items
end

-- Troca os placeholders de `text`. Retorna o texto expandido, ou nil + erro.
-- Salva os buffers citados que têm alterações (o Claude lê do disco).
---@param ctx claude.Context
function M.expand(text, ctx)
  local err
  local expanded = (" " .. text):gsub("(%s)@(%a+)", function(space, name)
    local fn = placeholders[name]
    if not fn or err then
      return nil -- mantém o original
    end
    local value, msg = fn(ctx)
    if not value then
      err = msg
      return nil
    end
    return space .. value
  end)
  if err then
    return nil, err
  end
  for buf in pairs(ctx.save) do
    if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].modified then
      vim.api.nvim_buf_call(buf, function()
        vim.cmd("silent update")
      end)
    end
  end
  return vim.trim(expanded)
end

return M
