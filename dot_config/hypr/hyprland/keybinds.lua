-- Todos os atalhos, um bloco por contexto. A tecla fica escrita na própria bind.
-- Convenção (Omarchy), com os especiais no formato do Caelestia:
--   SUPER + tecla                janelas, workspaces e workspaces especiais (e o
--                                Discord e o Obsidian, que eram especiais)
--   SUPER + SHIFT + letra        abre um app (letra em inglês: B = Browser, F = Files...)
--   SUPER + SHIFT + ALT + letra  variante do mesmo app
--   SUPER + CTRL + tecla         sistema, shell, capturas e mídia; e a versão "mais forte"
--                                de uma ação de janela (fechar todas, trocar de
--                                lugar, mover sem seguir)
--   SUPER + ALT + tecla          variante da ação de SUPER + tecla
-- Descrição no formato "Categoria: ação" (dots-hyprland): a cola do SUPER+F1
-- agrupa pela categoria.
-- Atalho novo: uma linha no bloco certo, bind(tecla, descrição, ação).
local F = require("utils.functions")
local W = require("utils.workspaces")
local vars = require("variables")
local bind, run, app, ipc, cmd_present, toggle = F.bind, F.run, F.app, F.ipc, F.cmd_present, F.toggle
local locked = { locked = true }
local repeating = { repeating = true }

-- ===== Apps =====
-- Terminal, navegador, arquivos e editor abrem sempre uma janela nova; os apps
-- de janela única focam a que já existe (launch-or-focus). G6
bind("SUPER + Return", "Apps: terminal", run(vars.terminal))
bind("SUPER + ALT + Return", "Apps: terminal with tmux (session main)", run(vars.tmuxTerminal))
bind("SUPER + SHIFT + B", "Apps: browser", run(vars.browser))
bind("SUPER + SHIFT + ALT + B", "Apps: browser, private window", run(vars.privateBrowser))
bind("SUPER + SHIFT + F", "Apps: files (yazi)", run(vars.fileExplorer))
bind("SUPER + SHIFT + N", "Apps: Neovim", run(vars.editor))
if cmd_present("obs") then
	bind("SUPER + SHIFT + R", "Apps: OBS (record)", app("^com\\.obsproject\\.Studio$", vars.obs))
end
if cmd_present("k9s") then
	bind("SUPER + SHIFT + P", "Apps: k9s (pods)", app("^com\\.mauricio\\.k9s$", vars.k9s))
end
-- Discord e Obsidian: eram especiais (communication e notes) e viraram janelas
-- normais (Omarchy). As teclas são as dos antigos especiais, sem SHIFT, pela
-- memória muscular: abrem o app ou vão até a janela dele.
bind("SUPER + D", "Apps: Discord", app("^(discord|vesktop)$", vars.discord))
bind("SUPER + R", "Apps: Obsidian (notes)", app("^md\\.obsidian\\.Obsidian$", vars.obsidian))
bind({ "SUPER + F1", "SUPER + slash" }, "Apps: keybinds cheatsheet", run(F.bin .. "keybinds --window"))

-- ===== Workspaces especiais =====
-- Abrem por cima de tudo; a mesma tecla esconde. Se o app não está rodando, abre;
-- se está em outro workspace, traz (utils/functions.lua, toggle). Apps em variables.lua.
bind("SUPER + M", "Special: music (Spotify)", toggle("music"))
bind("CTRL + SHIFT + escape", "Special: system monitor (btop)", toggle("sysmon"))

-- Scratchpad: especial vazio por cima de tudo; você manda as janelas.
-- Com outro especial aberto, a tecla fecha esse especial (specialWsCloseAny).
bind({ "SUPER + S", "SUPER + mouse:275" }, "Special: scratchpad (or close the open one)", F.toggle_scratch)
bind("SUPER + ALT + S", "Special: move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratch", follow = false }))
-- tira a janela do especial e a põe no workspace normal em foco (Caelestia)
bind("SUPER + CTRL + SHIFT + down", "Special: move window out to the workspace", hl.dsp.window.move({ workspace = "e+0" }))

-- ===== Jogos =====
-- Steam normal; no gamescope, sai dele para a janela da Steam
bind("SUPER + SHIFT + G", "Games: Steam", run(F.bin .. "steam-bigpicture --desktop"))
if cmd_present("heroic") then
	bind("SUPER + SHIFT + ALT + G", "Games: Heroic", app("^heroic$", vars.heroic))
end
-- Big Picture na tela pedida (~/.local/bin/steam-bigpicture); de novo, fecha.
-- G: a Steam normal, no workspace atual; B (de "box"): a Steam inteira dentro
-- do gamescope, que na TV oferece HDR aos jogos. Com ALT, na TV (liga se
-- estiver desligada). Os jogos abrem no 10 da tela (apps/games.lua),
-- então não tiram a tela cheia do Big Picture
bind("SUPER + CTRL + SHIFT + G", "Games: Big Picture on the monitor", run(F.bin .. "steam-bigpicture --monitor"))
bind("SUPER + CTRL + SHIFT + ALT + G", "Games: Big Picture on the TV", run(F.bin .. "steam-bigpicture --tv"))
bind("SUPER + CTRL + SHIFT + B", "Games: Big Picture in gamescope on the monitor", run(F.bin .. "steam-bigpicture --monitor --gamescope"))
bind("SUPER + CTRL + SHIFT + ALT + B", "Games: Big Picture in gamescope on the TV (HDR)", run(F.bin .. "steam-bigpicture --tv --gamescope"))
-- HUD do modo console (mangoapp): começa oculto, e o Shift_R+F12 só funciona
-- com ele visível; no desktop, o HUD do jogo usa o Shift_R+F12. Só com o
-- gamescope aberto: o recado fica na fila do mangoapp até alguém ler, e um
-- toque no desktop mudaria o HUD do próximo modo console
bind(
	"SUPER + F12",
	"Games: show/hide the gamescope HUD",
	run("sh -c 'pgrep -f \"^gamescope .*--mangoapp\" >/dev/null && exec mangohudctl toggle no_display'")
)

-- ===== Shell (Noctalia): launcher, painéis, notificações =====
bind("SUPER + space", "Shell: launcher", ipc("panel-toggle launcher"))
bind("SUPER + N", "Shell: control center", ipc("panel-toggle control-center"))
bind("SUPER + CTRL + A", "Shell: audio panel", ipc("panel-toggle control-center audio"))
bind("SUPER + CTRL + B", "Shell: bluetooth panel", ipc("panel-toggle control-center bluetooth"))
bind("SUPER + comma", "Shell: Noctalia settings", ipc("settings-toggle"))
bind("SUPER + SHIFT + space", "Shell: show/hide the bar", ipc("bar-toggle"))
bind("ALT + Tab", "Shell: window switcher", ipc("window-switcher hold"))
bind("ALT + SHIFT + Tab", "Shell: window switcher (reverse)", ipc("window-switcher hold reverse"))
bind("SUPER + V", "Shell: clipboard history", ipc("panel-toggle clipboard"))
bind("SUPER + period", "Shell: emoji picker", ipc('panel-toggle launcher "/emo"'))
bind("SUPER + CTRL + W", "Shell: wallpaper picker", ipc('panel-toggle launcher "/wall"'))
bind("SUPER + CTRL + SHIFT + D", "Shell: dark/light theme", ipc("theme-mode-toggle"))
bind("SUPER + CTRL + N", "Shell: night light", ipc("nightlight-toggle"))
bind("SUPER + CTRL + I", "Shell: keep awake (caffeine)", ipc("caffeine-toggle"))
-- reinicia o Noctalia (Caelestia): espera o antigo sair e abre de novo pelo uwsm
bind(
	"SUPER + CTRL + ALT + R",
	"Shell: restart Noctalia",
	"sh -c 'pkill -x noctalia; while pgrep -x noctalia >/dev/null; do sleep 0.1; done; exec uwsm app -- noctalia'"
)

-- Notificações: SUPER + vírgula e variantes
bind("SUPER + SHIFT + comma", "Notifications: clear", ipc("notification-clear-active"))
bind("SUPER + CTRL + comma", "Notifications: do not disturb", ipc("notification-dnd-toggle"))
bind("SUPER + ALT + comma", "Notifications: open the latest", ipc("notification-invoke-latest"))
bind("SUPER + SHIFT + ALT + comma", "Notifications: history", ipc("panel-toggle control-center notifications"))

-- ===== Sessão =====
-- Para sair do Hyprland, use o menu (pede confirmação)
bind("SUPER + escape", "Session: lock screen", ipc("session lock"))
bind({ "SUPER + SHIFT + escape", "CTRL + ALT + Delete" }, "Session: menu", ipc("panel-toggle session"))
-- O shell caiu com a tela bloqueada: abre o Noctalia de novo e bloqueia (Caelestia).
-- Complementa o allow_session_lock_restore (hyprland/misc.lua).
bind(
	"SUPER + ALT + escape",
	"Session: restore the lock screen",
	"sh -c 'pgrep -x noctalia >/dev/null || { uwsm app -- noctalia & sleep 2; }; noctalia msg session lock'",
	locked
)

-- ===== Captura: telas (Noctalia) e seletor de cor =====
-- Em SUPER+CTRL, sem a tecla Print: o teclado (Skyloong GK75) não tem.
-- S de screenshot, com SHIFT a tela inteira e com ALT a janela; E de editar
bind("SUPER + CTRL + S", "Capture: screenshot of a region", ipc("screenshot-region"))
bind("SUPER + CTRL + SHIFT + S", "Capture: screenshot of the screen", ipc("screenshot-fullscreen"))
bind("SUPER + CTRL + ALT + S", "Capture: screenshot of a window", ipc("screenshot-window"))
bind("SUPER + CTRL + E", "Capture: screenshot with annotations", ipc("screenshot-annotate"))
-- a segunda vez cancela o seletor aberto (Omarchy)
bind("SUPER + CTRL + C", "Capture: color picker", "pkill hyprpicker || hyprpicker -a")

-- ===== Janelas =====
bind({ "SUPER + Q", "SUPER + W" }, "Window: close", hl.dsp.window.close())
-- mata o processo da janela que você clicar, para app travado (dots-hyprland)
bind("SUPER + CTRL + ALT + Q", "Window: kill the clicked window (frozen app)", "hyprctl kill")
-- fecha as janelas do workspace em foco (Omarchy fecha as de todos). P3
bind("SUPER + CTRL + Q", "Window: close all on this workspace", function()
	local ws = hl.get_active_workspace()
	if not ws then
		return
	end
	for _, w in ipairs(hl.get_windows()) do
		if w.workspace and w.workspace.id == ws.id then
			hl.dispatch(hl.dsp.window.close({ window = "address:" .. w.address }))
		end
	end
end)
bind("SUPER + F", "Window: fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind("SUPER + ALT + F", "Window: maximize", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
-- o app acha que está em tela cheia e a janela continua no tiling: vídeo do
-- navegador sem barras, dentro da janela (Omarchy)
bind("SUPER + CTRL + F", "Window: fullscreen inside the tile", function()
	local w = hl.get_active_window()
	if not w then
		return
	end
	local client = (w.fullscreen_client or 0) == 2 and 0 or 2
	hl.dispatch(hl.dsp.window.fullscreen_state({ internal = w.fullscreen or 0, client = client, action = "set" }))
end)
-- Voltar ao tiling solta o pin sozinho, mas sem reavaliar as regras: a borda de
-- janela fixada e a tag do pop-out (SUPER+P) ficavam. Por isso o pin e a tag
-- saem antes, pelos dispatchers, que reavaliam as regras.
bind("SUPER + T", "Window: float/tile", function()
	local w = hl.get_active_window()
	if not w then
		return
	end
	local sel = "address:" .. w.address
	if w.floating then
		if w.pinned then
			hl.dispatch(hl.dsp.window.pin({ window = sel, action = "disable" }))
		end
		if F.has_tag(w, "pop") then
			hl.dispatch(hl.dsp.window.tag({ window = sel, tag = "-pop" }))
		end
	end
	hl.dispatch(hl.dsp.window.float({ window = sel, action = "toggle" }))
end)
bind("SUPER + Y", "Window: split direction", hl.dsp.layout("togglesplit"))
-- proporção da divisão em passos de 10% (dots-hyprland)
bind("SUPER + semicolon", "Window: split ratio smaller", hl.dsp.layout("splitratio -0.1"), repeating)
bind("SUPER + apostrophe", "Window: split ratio larger", hl.dsp.layout("splitratio +0.1"), repeating)

-- Pop-out que vai e volta (Omarchy): flutua, centraliza, fixa em todos os
-- workspaces e ganha a tag "pop"; de novo, volta ao tiling. Também desfaz o
-- pop-out pequeno (SUPER+ALT+P), que fixa sem a tag. A recentralização ao
-- trocar de monitor fica em hyprland/rules.lua.
bind("SUPER + P", "Window: pop out / back in", function()
	local w = hl.get_active_window()
	if not w then
		return
	end
	local sel = "address:" .. w.address
	if F.has_tag(w, "pop") or (w.floating and w.pinned) then
		hl.dispatch(hl.dsp.window.pin({ window = sel, action = "disable" }))
		hl.dispatch(hl.dsp.window.float({ window = sel, action = "disable" }))
		hl.dispatch(hl.dsp.window.tag({ window = sel, tag = "-pop" }))
	else
		hl.dispatch(hl.dsp.window.float({ window = sel, action = "enable" }))
		hl.dispatch(hl.dsp.window.center({ window = sel }))
		hl.dispatch(hl.dsp.window.pin({ window = sel, action = "enable" }))
		hl.dispatch(hl.dsp.window.tag({ window = sel, tag = "+pop" }))
	end
end)
-- Pop-out pequeno no canto inferior direito, com ¼ da altura da tela (Caelestia)
bind("SUPER + ALT + P", "Window: small pop-out in the corner", function()
	local w = hl.get_active_window()
	local m = hl.get_active_monitor()
	if not (w and w.size and m) then
		return
	end
	local sel = "address:" .. w.address
	local mw, mh = m.width / m.scale, m.height / m.scale
	local scale = (mh / 4) / w.size.y
	local width = math.floor(math.max(200, w.size.x * scale))
	local height = math.floor(math.max(150, w.size.y * scale))
	local offset = math.min(mw, mh) * 0.03
	hl.dispatch(hl.dsp.window.float({ window = sel, action = "enable" }))
	hl.dispatch(hl.dsp.window.resize({ window = sel, x = width, y = height }))
	hl.dispatch(hl.dsp.window.move({
		window = sel,
		x = math.floor(m.x + mw - width - offset),
		y = math.floor(m.y + mh - height - offset),
		relative = false,
	}))
	hl.dispatch(hl.dsp.window.pin({ window = sel, action = "enable" }))
end)
bind("SUPER + CTRL + backslash", "Window: center", hl.dsp.window.center())
-- "normalizar": flutua em 55% × 70% da tela, centralizada (Caelestia)
bind("SUPER + CTRL + ALT + backslash", "Window: float at a normal size", function()
	local size = F.resize_by_screen(55, 70)
	if not size then
		return
	end
	hl.dispatch(hl.dsp.window.float({ action = "enable" }))
	hl.dispatch(hl.dsp.window.resize(size))
	hl.dispatch(hl.dsp.window.center())
end)

-- Transparência da janela em foco: liga e desliga o opaque (Omarchy). Vale até
-- a janela fechar. O jogo já nasce opaco (tag game, apps/games.lua): o
-- primeiro toque nele o deixa transparente, em vez de não fazer nada.
local opaque = {}
bind("SUPER + BackSpace", "Window: transparency on/off", function()
	local w = hl.get_active_window()
	if not w then
		return
	end
	local now = opaque[w.address]
	if now == nil then
		now = F.has_tag(w, "game")
	end
	opaque[w.address] = not now
	hl.dispatch(hl.dsp.window.set_prop({
		window = "address:" .. w.address,
		prop = "opaque",
		value = opaque[w.address] and "1" or "0",
	}))
end)

-- Alterna o foco entre janelas em tiling e flutuantes; apertando de novo nas
-- flutuantes, passa para a próxima (snippet da doc do Hyprland, i3 "focus mode_toggle").
-- SUPER+Space é o launcher, por isso o ALT.
bind("SUPER + ALT + space", "Window: focus tiled/floating", function()
	local window = hl.get_active_window()
	if not window then
		return
	end
	hl.dispatch(hl.dsp.window.cycle_next({
		floating = not window.floating,
		tiled = window.floating,
	}))
end)

-- Foco, mover e trocar: hjkl e setas
local dirs = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(dirs) do
	bind("SUPER + " .. key, "Window: focus " .. dir, hl.dsp.focus({ direction = dir }))
	bind("SUPER + SHIFT + " .. key, "Window: move " .. dir, hl.dsp.window.move({ direction = dir }))
	bind("SUPER + CTRL + " .. key, "Window: swap " .. dir, hl.dsp.window.swap({ direction = dir }))
end
for _, dir in ipairs({ "left", "down", "up", "right" }) do
	bind("SUPER + " .. dir, "Window: focus " .. dir, hl.dsp.focus({ direction = dir }))
	bind("SUPER + SHIFT + " .. dir, "Window: move " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Redimensionar em % do tamanho da janela (Caelestia): segure SUPER+ALT+hjkl;
-- SUPER+menos/igual na largura, SUPER+SHIFT+menos/igual na altura (Omarchy)
local step = vars.resizePercent
local resize = F.resize_active_window
local grow = { h = { -step, 0 }, j = { 0, step }, k = { 0, -step }, l = { step, 0 } }
for key, d in pairs(grow) do
	bind("SUPER + ALT + " .. key, "Window: resize", resize(d[1], d[2]), repeating)
end
bind("SUPER + minus", "Window: narrower", resize(-step, 0), repeating)
bind("SUPER + equal", "Window: wider", resize(step, 0), repeating)
bind("SUPER + SHIFT + minus", "Window: shorter", resize(0, -step), repeating)
bind("SUPER + SHIFT + equal", "Window: taller", resize(0, step), repeating)

-- Mouse: SUPER + arrastar move (esquerdo) ou redimensiona (direito). Segurando
-- SUPER+Z ou SUPER+X, o mouse move ou redimensiona sem botão (Caelestia).
bind({ "SUPER + mouse:272", "SUPER + Z" }, "Window: drag with the mouse", hl.dsp.window.drag(), { mouse = true })
bind({ "SUPER + mouse:273", "SUPER + X" }, "Window: resize with the mouse", hl.dsp.window.resize(), { mouse = true })

-- ===== Grupos (abas dentro de uma mesma área) =====
bind("SUPER + G", "Group: on/off", hl.dsp.group.toggle())
bind("SUPER + ALT + G", "Group: take window out", hl.dsp.window.move({ out_of_group = true }))
-- travado, nenhuma janela entra ou sai do grupo (Caelestia)
bind("SUPER + CTRL + G", "Group: lock/unlock", hl.dsp.group.lock({ action = "toggle" }))
bind({ "SUPER + CTRL + Left", "SUPER + ALT + SHIFT + Tab" }, "Group: previous tab", hl.dsp.group.prev())
bind({ "SUPER + CTRL + Right", "SUPER + ALT + Tab" }, "Group: next tab", hl.dsp.group.next())
-- entrar no grupo vizinho (Omarchy)
for _, d in ipairs({ { "Left", "l" }, { "Right", "r" }, { "Up", "u" }, { "Down", "d" } }) do
	bind("SUPER + ALT + " .. d[1], "Group: move window into the group " .. d[1]:lower(), hl.dsp.window.move({ into_group = d[2] }))
end

-- ===== Workspaces e monitores (veja utils/workspaces.lua) =====
-- SUPER + 1…0: workspace da tela em foco (a tecla 0 é o 10);
-- com ALT, na próxima tela, em ciclo
for slot = 1, 10 do
	local key = slot % 10
	bind("SUPER + " .. key, "Workspace: go to " .. slot, function()
		W.focus(slot)
	end)
	bind("SUPER + ALT + " .. key, "Workspace: go to " .. slot .. " on the next screen", function()
		W.focus(slot, true)
	end)
	bind("SUPER + SHIFT + " .. key, "Workspace: move window to " .. slot, function()
		W.move(slot, true)
	end)
	bind("SUPER + CTRL + " .. key, "Workspace: move window to " .. slot .. " (stay)", function()
		W.move(slot, false)
	end)
end

-- m+1: só os workspaces do monitor em foco (Omarchy)
bind({ "SUPER + Tab", "SUPER + mouse_down", "SUPER + Page_Down" }, "Workspace: next", hl.dsp.focus({ workspace = "m+1" }))
bind({ "SUPER + SHIFT + Tab", "SUPER + mouse_up", "SUPER + Page_Up" }, "Workspace: previous", hl.dsp.focus({ workspace = "m-1" }))
bind("SUPER + CTRL + Tab", "Workspace: last used", hl.dsp.focus({ workspace = "previous" }))
bind({ "SUPER + SHIFT + Page_Down", "SUPER + ALT + mouse_down" }, "Workspace: move window to the next", hl.dsp.window.move({ workspace = "+1" }))
bind({ "SUPER + SHIFT + Page_Up", "SUPER + ALT + mouse_up" }, "Workspace: move window to the previous", hl.dsp.window.move({ workspace = "-1" }))

-- Monitores (O = output)
bind("SUPER + O", "Monitor: focus the other", hl.dsp.focus({ monitor = "+1" }))
bind("SUPER + CTRL + SHIFT + O", "Monitor: move window to the other", hl.dsp.window.move({ monitor = "+1" }))
bind("SUPER + CTRL + O", "Monitor: move workspace to the other", hl.dsp.workspace.move({ monitor = "+1" }))
bind("SUPER + ALT + O", "Monitor: TV on/off", F.bin .. "tv-toggle")

-- ===== Tela: zoom e modo sem distração =====
-- Zoom em passos de 0,3, entre 1 e 3 (dots-hyprland; teclas do Omarchy)
local function zoom(delta)
	return function()
		local z = (hl.get_config("cursor.zoom_factor") or 1) + delta
		hl.config({ cursor = { zoom_factor = math.max(1, math.min(3, z)) } })
	end
end
bind("SUPER + CTRL + Z", "Screen: zoom in", zoom(0.3), repeating)
bind("SUPER + CTRL + SHIFT + Z", "Screen: zoom out", zoom(-0.3), repeating)
bind("SUPER + CTRL + ALT + Z", "Screen: reset zoom", function()
	hl.config({ cursor = { zoom_factor = 1 } })
end)

-- Sem margens e sem bordas (Omarchy, sem arquivo de estado: vale até o
-- próximo reload). Guarda os valores de agora para voltar a eles.
local saved_gaps
bind("SUPER + SHIFT + BackSpace", "Screen: no gaps or borders on/off", function()
	if saved_gaps then
		hl.config({ general = saved_gaps })
		saved_gaps = nil
	else
		saved_gaps = {
			gaps_in = hl.get_config("general.gaps_in"),
			gaps_out = hl.get_config("general.gaps_out"),
			border_size = hl.get_config("general.border_size"),
		}
		hl.config({ general = { gaps_in = 0, gaps_out = 0, border_size = 0 } })
	end
end)

-- ===== Mídia e volume pelo Noctalia (funcionam com a tela bloqueada) =====
bind("XF86AudioRaiseVolume", "Media: volume up", ipc("volume-up"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Media: volume down", ipc("volume-down"), { locked = true, repeating = true })
-- de 1 em 1 (Omarchy)
bind("ALT + XF86AudioRaiseVolume", "Media: volume up by 1", ipc("volume-up 1"), { locked = true, repeating = true })
bind("ALT + XF86AudioLowerVolume", "Media: volume down by 1", ipc("volume-down 1"), { locked = true, repeating = true })
-- sem teclas multimídia: SUPER+CTRL + M (mudo; com SHIFT, o microfone),
-- espaço, igual, menos, BackSpace (Caelestia)
bind({ "XF86AudioMute", "SUPER + CTRL + M" }, "Media: mute", ipc("volume-mute"), locked)
bind({ "XF86AudioMicMute", "SUPER + CTRL + SHIFT + M" }, "Media: microphone mute", ipc("mic-mute"), locked)
bind({ "XF86AudioPlay", "XF86AudioPause", "SUPER + CTRL + space" }, "Media: play/pause", ipc("media toggle"), locked)
bind({ "XF86AudioNext", "SUPER + CTRL + equal" }, "Media: next", ipc("media next"), locked)
bind({ "XF86AudioPrev", "SUPER + CTRL + minus" }, "Media: previous", ipc("media previous"), locked)
bind({ "XF86AudioStop", "SUPER + CTRL + BackSpace" }, "Media: stop", ipc("media stop"), locked)

-- ===== Sistema =====
bind("SUPER + CTRL + R", "System: reload Hyprland config", hl.dsp.reload_config())

-- Desliga todos os atalhos até apertar SUPER+ALT+F1 de novo: para VM, área de
-- trabalho remota e jogo que usa a tecla SUPER (dots-hyprland)
local function passthrough()
	if hl.get_current_submap() == "passthrough" then
		hl.dispatch(ipc("notification-show 'Keybinds on' 'Hyprland shortcuts are back'"))
		hl.dispatch(hl.dsp.submap("reset"))
	else
		hl.dispatch(ipc("notification-show 'Keybinds off' 'Press SUPER+ALT+F1 to turn them back on'"))
		hl.dispatch(hl.dsp.submap("passthrough"))
	end
end
hl.define_submap("passthrough", function()
	bind("SUPER + ALT + F1", "System: all keybinds off/on (VM, remote desktop)", passthrough, { submap_universal = true })
end)
