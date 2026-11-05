-- Workspaces por monitor (ideia do Omarchy, simplificada para as telas fixas deste PC).
--
-- Cada app tem um número fixo de 1 a 10. O que muda com as telas é o bloco:
--   só o monitor atual        1–10 nele; o 10 (jogos) também
--   atual + TV                1–9 no atual; o 10 (jogos) na TV
--   QHD + atual               1–10 no QHD; chat, media, tools e stores em 11–20 no atual
--   QHD + atual + TV          igual, com o 10 (jogos) na TV
-- O SUPER+número vai para o número do monitor em foco (no secundário, 3 = 13).
-- Quando uma tela liga ou desliga, reconcile() renumera os workspaces (3 ↔ 13)
-- e leva cada um ao monitor certo.
local screens = require("monitors")

local W = {}

local GAMES = 10
W.GAMES = GAMES
-- mapa por app (o nome fica só no comentário; a barra mostra o número da tecla)
local apps = { "dev", "web", "chat", "notes", "media", "tools", nil, "stores", nil, "games" }
-- números que vão para o secundário quando ele existe
local secondary_slots = { [3] = true, [5] = true, [6] = true, [8] = true }
-- Regras de nome e de "sempre visível" (persistent), um conjunto por layout:
--   single  um monitor: os 8 do mapa fixos em 1–10
--   dual    dois monitores: dev, web, notes e games no principal; chat, media,
--           tools e stores em 13, 15, 16 e 18 no secundário
-- reconcile() liga só o conjunto do layout atual. Com um só conjunto, um 3
-- persistente voltaria a existir logo depois de virar 13.
-- Só os números que mudam (3, 5, 6, 8 ↔ 13, 15, 16, 18) têm duas regras: duas
-- regras para o mesmo número se sobrepõem, e a desligada anula a outra.
local ws_rules = { single = {}, dual = {} }

-- O nome do workspace é o número da tecla (13 se chama "3"), como no Omarchy:
-- cada monitor mostra 1–10 na barra (Noctalia com label_source = "name").
local function rule(id, slot, set)
	local r = hl.workspace_rule({
		workspace = tostring(id),
		default_name = tostring(slot),
		persistent = apps[slot] ~= nil,
		enabled = set ~= "dual",
	})
	if set then
		table.insert(ws_rules[set], r)
	end
end

for slot = 1, 10 do
	if secondary_slots[slot] then
		rule(slot, slot, "single")
		rule(slot + 10, slot, "dual")
	else
		rule(slot, slot) -- igual nos dois layouts, sempre ligada
	end
end

-- ===== Telas ativas =====
local function active(name)
	if not name then
		return nil
	end
	for _, m in ipairs(hl.get_monitors()) do
		if m.name == name then
			return m
		end
	end
end

function W.layout()
	local qhd = active(screens.qhd)
	local current = active(screens.current)
	local primary = qhd or current or hl.get_active_monitor() -- VM: a única tela
	return {
		primary = primary,
		secondary = qhd and current or nil,
		games = active(screens.tv) or primary,
	}
end

-- Monitor dono de um workspace
local function owner(id, layout)
	if id == GAMES then
		return layout.games
	end
	if id > 10 then
		return layout.secondary or layout.primary
	end
	return layout.primary
end

-- Número real de um slot (1–10) no monitor m. O 10 é sempre o dos jogos:
-- no secundário, SUPER+0 não vira um 20.
local function workspace_id(slot, m, layout)
	if slot == GAMES then
		return GAMES
	end
	if layout.secondary and m and m.name == layout.secondary.name then
		return slot + 10
	end
	return slot
end

local function other_monitor(m, layout)
	if layout.secondary and m and m.name == layout.primary.name then
		return layout.secondary
	end
	return layout.primary
end

-- Quantos workspaces normais estão no monitor
local function count_on(monitor_name)
	local n = 0
	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id and ws.id > 0 and not ws.special and ws.monitor and ws.monitor.name == monitor_name then
			n = n + 1
		end
	end
	return n
end

-- Leva o workspace ao monitor dono, se estiver em outro
local function place(id, layout)
	local ws = hl.get_workspace(id)
	local m = owner(id, layout)
	if not (ws and ws.monitor and m) or ws.monitor.name == m.name then
		return
	end
	-- nunca tira o único workspace de uma tela: o Hyprland criaria outro nela,
	-- que seria movido de novo, em loop (a tela pisca)
	if count_on(ws.monitor.name) <= 1 then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = m.name }))
end

-- Muda o número de um workspace, com as janelas (3 → 13 e volta)
local function renumber(from, to)
	if not hl.get_workspace(from) then
		return
	end
	if not hl.get_workspace(to) then
		hl.dispatch(hl.dsp.workspace.change_id({ workspace = tostring(from), id = to }))
		return
	end
	-- o destino já existe: move janela por janela
	for _, w in ipairs(hl.get_windows()) do
		if w.workspace and w.workspace.id == from then
			hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = tostring(to), follow = false }))
		end
	end
end

-- ===== Regras de app: o workspace depende do bloco =====
local app_rules = {}

-- W.app(name, match, slot): manda o app para o slot no monitor certo
function W.app(name, match, slot)
	local single = hl.window_rule({ name = name, match = match, workspace = tostring(slot) })
	if secondary_slots[slot] then
		local dual = hl.window_rule({ name = name .. "-secondary", match = match, workspace = tostring(slot + 10), enabled = false })
		table.insert(app_rules, { single = single, dual = dual })
	end
end

function W.reconcile()
	local layout = W.layout()
	if not layout.primary then
		return
	end
	local has_secondary = layout.secondary ~= nil
	-- primeiro as regras: assim o 3 deixa de ser persistente antes de virar 13
	for _, r in ipairs(ws_rules.single) do
		r:set_enabled(not has_secondary)
	end
	for _, r in ipairs(ws_rules.dual) do
		r:set_enabled(has_secondary)
	end
	for _, r in ipairs(app_rules) do
		r.single:set_enabled(not has_secondary)
		r.dual:set_enabled(has_secondary)
	end
	if has_secondary then
		for slot in pairs(secondary_slots) do
			renumber(slot, slot + 10)
		end
	else
		for id = 11, 20 do
			renumber(id, id - 10)
		end
	end
	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id and ws.id > 0 and not ws.special then
			place(ws.id, layout)
		end
	end
end

-- ===== Ações dos atalhos (binds/workspaces.lua) =====
-- Vai ao slot no monitor em foco, ou no outro monitor (on_other = true)
function W.focus(slot, on_other)
	local layout = W.layout()
	local m = hl.get_active_monitor()
	if on_other then
		m = other_monitor(m, layout)
	end
	local id = workspace_id(slot, m, layout)
	local target = owner(id, layout)
	place(id, layout)
	if not hl.get_workspace(id) and target and not target.focused then
		hl.dispatch(hl.dsp.focus({ monitor = target.name }))
	end
	hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
end

-- Move a janela ativa para o slot no monitor em foco
function W.move(slot, follow)
	local layout = W.layout()
	local id = workspace_id(slot, hl.get_active_monitor(), layout)
	hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = follow }))
	place(id, layout)
end

-- ===== Eventos =====
-- Um tempo depois do evento: mexer em monitores dentro dele pode travar o Hyprland
local function later(fn)
	hl.timer(fn, { type = "oneshot", timeout = 1 })
end

hl.on("hyprland.start", function()
	later(W.reconcile)
end)
-- direto, como no Omarchy: o timer aqui derruba o "Hyprland --verify-config"
hl.on("config.reloaded", function()
	W.reconcile()
end)
hl.on("monitor.layout_changed", function()
	later(W.reconcile)
end)
-- workspace novo (aberto por regra de app ou atalho) vai para o monitor dono
hl.on("workspace.created", function(ws)
	if ws and ws.id and ws.id > 0 and not ws.special then
		local id = ws.id
		later(function()
			place(id, W.layout())
		end)
	end
end)

return W
