-- Dez workspaces por tela (ideia do Omarchy, monitor-workspaces.lua, simplificada
-- para as telas fixas deste PC).
--
-- Cada tela configurada em variables.lua (screens) ganha um bloco de 10, na
-- ordem de screens.order. O bloco não muda quando a tela desliga:
--   sem o QHD no variables.lua   monitor 1–10, TV 11–20
--   com o QHD no variables.lua   QHD 1–10, monitor 11–20, TV 21–30
-- A barra mostra 1–10 em todas (o nome do workspace é o número da tecla).
-- O SUPER+número vai ao número da tela em foco. Nenhum número é de jogo: tudo
-- abre no workspace atual.
--
-- Quando uma tela desliga (a TV pelo SUPER+ALT+O), o Hyprland passa os
-- workspaces dela para outra tela. Eles ficam com o mesmo id, aparecem como
-- "TV 3" e voltam para ela quando ela religa (Omarchy). Quando o bloco de uma
-- tela muda (o QHD chegou e o monitor passou de 1–10 a 11–20), os workspaces
-- dela mudam de número junto, com as janelas.
-- Fixo pela configuração, e não pelas telas ligadas: o DP-2 pisca ao sair do
-- repouso, e um bloco que dependesse disso trocaria a TV de lugar no meio.
local screens = require("variables").screens

local W = {}

local SLOTS = 10

-- O nome é o número da tecla em qualquer bloco (o 13 se chama "3"). Cada id
-- fica ligado à tela do bloco, e o primeiro é o que ela mostra ao ligar (sem
-- isto, a TV ligava num número livre qualquer, como o 3)
local n = 0
for _, key in ipairs(screens.order) do
	-- screens também guarda tabelas (order, labels): só o nome da conexão conta
	local name = screens[key]
	if type(name) == "string" then
		for slot = 1, SLOTS do
			hl.workspace_rule({
				workspace = tostring(n * SLOTS + slot),
				default_name = tostring(slot),
				monitor = name,
				default = slot == 1 or nil,
			})
		end
		n = n + 1
	end
end
-- blocos das telas fora da lista (a VM): só o nome
for id = n * SLOTS + 1, (n + 2) * SLOTS do
	hl.workspace_rule({ workspace = tostring(id), default_name = tostring((id - 1) % SLOTS + 1) })
end

local function slot_of(id)
	return (id - 1) % SLOTS + 1
end

-- ===== Blocos =====
local function active_monitors()
	local by_name = {}
	for _, m in ipairs(hl.get_monitors() or {}) do
		by_name[m.name] = m
	end
	return by_name
end

-- Um bloco por tela configurada, ligada ou não: { key, base, monitor (nil se
-- desligada) }. Uma tela fora da lista (a VM, um projetor) ganha o bloco
-- seguinte; se nenhuma configurada estiver ligada (a VM), começa do 1.
function W.blocks()
	local on = active_monitors()
	local list, known, any = {}, {}, false
	for _, key in ipairs(screens.order) do
		local name = screens[key]
		if type(name) == "string" then
			known[name] = true
			list[#list + 1] = { key = key, base = #list * SLOTS, monitor = on[name] }
			any = any or on[name] ~= nil
		end
	end
	local next_base = any and #list * SLOTS or 0
	for name, m in pairs(on) do
		if not known[name] then
			list[#list + 1] = { key = name, base = next_base, monitor = m }
			next_base = next_base + SLOTS
		end
	end
	return list
end

-- Telas ligadas, na ordem dos blocos
local function active_blocks(list)
	local out = {}
	for _, b in ipairs(list) do
		if b.monitor then
			out[#out + 1] = b
		end
	end
	return out
end

-- Id do slot (1–10) na tela m
function W.id(slot, m)
	for _, b in ipairs(W.blocks()) do
		if m and b.monitor and b.monitor.name == m.name then
			return b.base + slot
		end
	end
	return slot
end

-- Tela dona de um id, ou nil se o bloco é de uma tela desligada
local function owner(id, list)
	local base = id - slot_of(id)
	for _, b in ipairs(list) do
		if b.base == base then
			return b.monitor
		end
	end
end

-- ===== Estado: bloco de cada tela na última passada =====
-- Num arquivo, porque o reload da config zera o Lua. Uma linha por tela:
-- "<chave> <primeiro id>". Serve para saber quando o bloco de uma tela mudou.
local STATE = (os.getenv("XDG_RUNTIME_DIR") or "/tmp") .. "/hypr-workspace-blocks"

local function load_state()
	local st = {}
	local f = io.open(STATE, "r")
	if f then
		for line in f:lines() do
			local key, base = line:match("^(%S+) (%d+)$")
			if key then
				st[key] = tonumber(base)
			end
		end
		f:close()
	end
	return st
end

local function save_state(st)
	local f = io.open(STATE, "w")
	if not f then
		return
	end
	for key, base in pairs(st) do
		f:write(key .. " " .. base .. "\n")
	end
	f:close()
end

-- Rótulo da tela dona de um id ("TV"), para o nome na barra
local function origin_label(id, list)
	local base = id - slot_of(id)
	for _, b in ipairs(list) do
		if b.base == base then
			return (screens.labels and screens.labels[b.key]) or b.key
		end
	end
end

-- ===== Ações =====
-- Quantos workspaces normais estão na tela
local function count_on(monitor_name)
	local n = 0
	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id and ws.id > 0 and not ws.special and ws.monitor and ws.monitor.name == monitor_name then
			n = n + 1
		end
	end
	return n
end

-- Muda o número de um workspace, com as janelas (do 3 para o 13)
local function renumber(from, to)
	if from == to or not hl.get_workspace(from) then
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

-- Leva o workspace à tela dona e acerta o nome na barra
local function place(id, list)
	local ws = hl.get_workspace(id)
	if not ws then
		return
	end
	local m = owner(id, list)
	local name = tostring(slot_of(id))
	if not m then
		-- tela desligada: fica onde o Hyprland o pôs, com o nome da tela de origem
		local from = origin_label(id, list)
		name = from and (from .. " " .. name) or name
	end
	if ws.name ~= name then
		hl.dispatch(hl.dsp.workspace.rename({ workspace = tostring(id), name = name }))
	end
	if not (m and ws.monitor) or ws.monitor.name == m.name then
		return
	end
	-- nunca tira o único workspace de uma tela: o Hyprland criaria outro nela,
	-- que seria movido de novo, em loop (a tela pisca)
	if count_on(ws.monitor.name) <= 1 then
		return
	end
	hl.dispatch(hl.dsp.workspace.move({ workspace = tostring(id), monitor = m.name }))
end

function W.reconcile()
	local list = W.blocks()
	if #active_blocks(list) == 0 then
		return
	end
	local old = load_state()
	local new = {}
	for _, b in ipairs(list) do
		new[b.key] = b.base
	end

	-- telas cujo bloco mudou (o QHD entrou no variables.lua): os workspaces delas
	-- mudam de número. Primeiro quem sobe, do bloco mais alto para o mais baixo;
	-- depois quem desce, do mais baixo para o mais alto. Assim ninguém cai num
	-- id ainda ocupado.
	local shifts = {}
	for key, base in pairs(new) do
		if old[key] and old[key] ~= base then
			shifts[#shifts + 1] = { from = old[key], to = base, up = base > old[key] }
		end
	end
	table.sort(shifts, function(a, b)
		if a.up ~= b.up then
			return a.up
		end
		if a.up then
			return a.from > b.from
		end
		return a.from < b.from
	end)
	for _, sh in ipairs(shifts) do
		for i = 1, SLOTS do
			local slot = sh.up and (SLOTS + 1 - i) or i
			renumber(sh.from + slot, sh.to + slot)
		end
	end
	save_state(new)

	for _, ws in ipairs(hl.get_workspaces()) do
		if ws.id and ws.id > 0 and not ws.special then
			place(ws.id, list)
		end
	end
end

-- ===== Ações dos atalhos (hyprland/keybinds.lua) =====
-- Próxima tela ligada, em ciclo (SUPER+ALT+número)
local function next_screen(m, list)
	local on = active_blocks(list)
	for i, b in ipairs(on) do
		if m and b.monitor.name == m.name then
			return on[i % #on + 1].monitor
		end
	end
	return on[1] and on[1].monitor
end

-- Vai ao slot na tela em foco, ou na próxima tela (on_other = true)
function W.focus(slot, on_other)
	local list = W.blocks()
	local m = hl.get_active_monitor()
	if on_other then
		m = next_screen(m, list)
	end
	local id = W.id(slot, m)
	if not hl.get_workspace(id) and m and not m.focused then
		hl.dispatch(hl.dsp.focus({ monitor = m.name }))
	end
	hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
	place(id, list)
end

-- Move a janela ativa para o slot na tela em foco
function W.move(slot, follow)
	local id = W.id(slot, hl.get_active_monitor())
	hl.dispatch(hl.dsp.window.move({ workspace = tostring(id), follow = follow }))
	place(id, W.blocks())
end

-- Tela de um papel, para os scripts (steam-bigpicture):
--   "tv"       a TV (precisa estar ligada)
--   "monitor"  a tela em foco, se não for a TV; senão a primeira ligada que não é a TV
--   "here"     a tela em foco
function W.target(role)
	local active = hl.get_active_monitor()
	if role == "here" then
		return active
	end
	if role == "tv" then
		for _, b in ipairs(W.blocks()) do
			if b.key == "tv" then
				return b.monitor
			end
		end
		return nil
	end
	if active and active.name ~= screens.tv then
		return active
	end
	for _, b in ipairs(active_blocks(W.blocks())) do
		if b.key ~= "tv" then
			return b.monitor
		end
	end
	return active
end

-- Foco na tela de um papel, no workspace que ela mostra; com slot, nesse
-- número dela: hyprctl eval 'require("utils.workspaces").go("tv")'
function W.go(role, slot)
	local m = W.target(role)
	if not m then
		return
	end
	if not m.focused then
		hl.dispatch(hl.dsp.focus({ monitor = m.name }))
	end
	if slot then
		local id = W.id(slot, m)
		hl.dispatch(hl.dsp.focus({ workspace = tostring(id) }))
		place(id, W.blocks())
	end
end

-- ===== Eventos =====
-- Um tempo depois do evento: mexer em monitores dentro dele pode travar o Hyprland
local function later(fn)
	hl.timer(fn, { type = "oneshot", timeout = 1 })
end

hl.on("hyprland.start", function()
	-- sessão nova: o estado de uma sessão anterior não vale
	os.remove(STATE)
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
hl.on("monitor.removed", function()
	later(W.reconcile)
end)
-- workspace novo (aberto por regra de app ou atalho) vai para a tela dona
hl.on("workspace.created", function(ws)
	if ws and ws.id and ws.id > 0 and not ws.special then
		local id = ws.id
		later(function()
			place(id, W.blocks())
		end)
	end
end)

return W
