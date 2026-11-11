-- Workspaces por monitor (ideia do Omarchy, simplificada para as telas fixas deste PC).
--
-- Nenhum app tem número fixo: a janela abre onde você está. A exceção é o 10,
-- dos jogos, que segue a TV. O que muda com as telas:
--   só o monitor atual        1–10 nele
--   atual + TV                1–9 no atual; o 10 (jogos) na TV
--   QHD + atual               1–9 e o 10 no QHD; 11–19 no atual
--   QHD + atual + TV          igual, com o 10 (jogos) na TV
-- O SUPER+número vai para o número do monitor em foco (no secundário, 3 = 13).
-- Quando o secundário some, reconcile() junta 13 → 3, e leva cada workspace ao
-- monitor certo.
local screens = require("variables").screens

local W = {}

local GAMES = 10
W.GAMES = GAMES

-- O nome do workspace é o número da tecla (13 se chama "3"), como no Omarchy:
-- cada monitor mostra 1–10 na barra (Noctalia com label_source = "name").
-- O 10 é sempre o dos jogos, então não existe um 20.
for slot = 1, 9 do
	hl.workspace_rule({ workspace = tostring(slot + 10), default_name = tostring(slot) })
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

-- Muda o número de um workspace, com as janelas (13 → 3)
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

function W.reconcile()
	local layout = W.layout()
	if not layout.primary then
		return
	end
	-- sem secundário, as janelas do 11–19 voltam para o 1–9
	if not layout.secondary then
		for id = 11, 19 do
			renumber(id, id - 10)
		end
	end
	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id and ws.id > 0 and not ws.special then
			place(ws.id, layout)
		end
	end
end

-- ===== Ações dos atalhos (hyprland/keybinds.lua) =====
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
-- O DP-2 se desconecta por um instante ao sair do repouso. Sem tela principal,
-- os workspaces vão para a TV, e a passada do layout_changed pode rodar antes
-- de ele voltar. O monitor.added só vem com o monitor pronto (doc de eventos Lua).
hl.on("monitor.added", function()
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
