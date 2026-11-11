-- Todos os atalhos, um bloco por contexto. A tecla fica escrita na própria bind.
-- Convenção (Omarchy):
--   SUPER + tecla                janelas e workspaces
--   SUPER + SHIFT + letra        app (letra em inglês: B = Browser, F = Files, G = Games...)
--   SUPER + SHIFT + ALT + letra  variante do mesmo app
--   SUPER + CTRL + tecla         sistema e shell
-- Atalho novo: uma linha no bloco certo, bind(tecla, descrição, ação).
local F = require("utils.functions")
local W = require("utils.workspaces")
local vars = require("variables")
local bind, run, app, ipc, cmd_present = F.bind, F.run, F.app, F.ipc, F.cmd_present

-- ===== Apps =====
bind("SUPER + Return", "Terminal", run(vars.terminal))
bind("SUPER + ALT + Return", "Terminal with tmux (session main)", run(vars.tmuxTerminal))
bind("SUPER + SHIFT + B", "Browser", app("^firefox$", vars.browser))
bind("SUPER + SHIFT + ALT + B", "Browser: private window", run(vars.privateBrowser))
bind("SUPER + SHIFT + F", "Files: yazi", run(vars.fileExplorer))
bind("SUPER + SHIFT + N", "Neovim", run(vars.editor))
bind("SUPER + SHIFT + O", "Obsidian", app("^md\\.obsidian\\.Obsidian$", "obsidian"))
bind("SUPER + SHIFT + D", "Discord", app("^discord$", "discord"))
if cmd_present("obs") then
	bind("SUPER + SHIFT + R", "Record: OBS", app("^com\\.obsproject\\.Studio$", vars.obs))
end
if cmd_present("k9s") then
	bind("SUPER + SHIFT + P", "Pods: k9s", app("^com\\.mauricio\\.k9s$", vars.k9s))
end
bind("SUPER + F1", "Keybinds cheatsheet", F.bin .. "keybinds --window")

-- ===== Workspaces especiais =====
-- Música: workspace especial "music". Abre o Spotify se não estiver rodando.
if cmd_present("spotify-launcher") then
	bind("SUPER + SHIFT + M", "Music: Spotify (toggle)", function()
		hl.dispatch(hl.dsp.exec_cmd("pgrep -x spotify >/dev/null || uwsm app -- spotify-launcher"))
		hl.dispatch(hl.dsp.workspace.toggle_special("music"))
	end)
end

-- Scratchpad: workspace especial vazio por cima de tudo; você manda as janelas
bind({ "SUPER + grave", "SUPER + mouse:275" }, "Scratchpad (toggle)", hl.dsp.workspace.toggle_special("scratch"))
bind("SUPER + SHIFT + grave", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratch", follow = false }))

-- ===== Jogos =====
-- Steam normal; no modo console, sai dele para a janela da Steam no workspace 8
bind("SUPER + SHIFT + G", "Games: Steam", run(F.bin .. "steam-console --desktop"))
if cmd_present("heroic") then
	bind("SUPER + SHIFT + ALT + G", "Games: Heroic", app("^heroic$", vars.heroic))
end
-- modo console: Steam no Big Picture dentro do gamescope, na TV (~/.local/bin/steam-console)
bind("SUPER + CTRL + SHIFT + G", "Games: Steam console mode on/off (gamescope)", run(F.bin .. "steam-console"))
-- variante: no monitor, com a TV desligada (alguém usando os apps da TV)
bind("SUPER + CTRL + SHIFT + ALT + G", "Games: Steam console mode on the monitor", run(F.bin .. "steam-console --monitor"))
-- HUD do modo console (mangoapp): começa oculto, e o Shift_R+F12 só funciona
-- com ele visível; no desktop, o HUD do jogo usa o Shift_R+F12. Só com o
-- gamescope aberto: o recado fica na fila do mangoapp até alguém ler, e um
-- toque no desktop mudaria o HUD do próximo modo console
bind(
	"SUPER + F12",
	"Games: show/hide the console mode HUD",
	run("sh -c 'pgrep -f \"^gamescope .*--mangoapp\" >/dev/null && exec mangohudctl toggle no_display'")
)

-- ===== Shell (Noctalia): launcher, painéis, notificações, sessão =====
bind("SUPER + space", "Launcher", ipc("panel-toggle launcher"))
bind("SUPER + S", "Control center", ipc("panel-toggle control-center"))
bind("SUPER + comma", "Noctalia settings", ipc("settings-toggle"))
bind("ALT + Tab", "Window switcher", ipc("window-switcher hold"))
bind("ALT + SHIFT + Tab", "Window switcher (reverse)", ipc("window-switcher hold reverse"))
bind("SUPER + V", "Clipboard history", ipc("panel-toggle clipboard"))
bind("SUPER + period", "Emoji picker", ipc('panel-toggle launcher "/emo"'))
bind("SUPER + CTRL + W", "Wallpaper picker", ipc('panel-toggle launcher "/wall"'))
bind("SUPER + CTRL + SHIFT + D", "Dark/light theme toggle", ipc("theme-mode-toggle"))
bind("SUPER + CTRL + N", "Night light toggle", ipc("nightlight-toggle"))

-- Notificações: SUPER + vírgula e variantes
bind("SUPER + SHIFT + comma", "Notifications: clear", ipc("notification-clear-active"))
bind("SUPER + CTRL + comma", "Notifications: do not disturb", ipc("notification-dnd-toggle"))

-- Sessão: para sair do Hyprland, use o menu (pede confirmação)
bind("SUPER + escape", "Lock screen", ipc("session lock"))
bind("SUPER + SHIFT + escape", "Session menu", ipc("panel-toggle session"))

-- ===== Captura: telas (Noctalia) e seletor de cor =====
bind("Print", "Screenshot: region", ipc("screenshot-region"))
bind("SHIFT + Print", "Screenshot: window", ipc("screenshot-window"))
bind("CTRL + Print", "Screenshot: full screen", ipc("screenshot-fullscreen"))
-- o mesmo do Print, para quando o teclado pede Fn
bind("SUPER + SHIFT + S", "Screenshot: region", ipc("screenshot-region"))
bind("SUPER + SHIFT + A", "Screenshot: annotate", ipc("screenshot-annotate"))
bind("SUPER + SHIFT + C", "Color picker", "hyprpicker -a")

-- ===== Janelas: fechar, tela cheia, foco, mover, redimensionar =====
bind({ "SUPER + Q", "SUPER + W" }, "Close window", hl.dsp.window.close())
bind("SUPER + F", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind("SUPER + M", "Maximize", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
bind("SUPER + T", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
bind("SUPER + Y", "Toggle split direction", hl.dsp.layout("togglesplit"))

-- "Pop-out": a janela flutua e fica fixa em todos os workspaces (vídeo, anotações)
bind("SUPER + P", "Pop-out: float and pin", function()
	hl.dispatch(hl.dsp.window.float({ action = "set" }))
	hl.dispatch(hl.dsp.window.pin())
end)

-- Alterna o foco entre janelas em tiling e flutuantes; apertando de novo nas
-- flutuantes, passa para a próxima (snippet da doc do Hyprland, i3 "focus mode_toggle").
-- SUPER+Space é o launcher, por isso o ALT.
bind("SUPER + ALT + space", "Focus: toggle tiled/floating", function()
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
	bind("SUPER + " .. key, "Focus " .. dir, hl.dsp.focus({ direction = dir }))
	bind("SUPER + SHIFT + " .. key, "Move window " .. dir, hl.dsp.window.move({ direction = dir }))
	bind("SUPER + CTRL + " .. key, "Swap window " .. dir, hl.dsp.window.swap({ direction = dir }))
end
for _, dir in ipairs({ "left", "down", "up", "right" }) do
	bind("SUPER + " .. dir, "Focus " .. dir, hl.dsp.focus({ direction = dir }))
	bind("SUPER + SHIFT + " .. dir, "Move window " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Redimensionar: segure SUPER+ALT+hjkl; SUPER+menos/igual na largura,
-- SUPER+SHIFT+menos/igual na altura (Omarchy)
local step = vars.resizeStep
local function resize(x, y)
	return hl.dsp.window.resize({ x = x, y = y, relative = true })
end
local grow = { h = { -step, 0 }, j = { 0, step }, k = { 0, -step }, l = { step, 0 } }
for key, d in pairs(grow) do
	bind("SUPER + ALT + " .. key, "Resize window", resize(d[1], d[2]), { repeating = true })
end
bind("SUPER + minus", "Shrink width", resize(-step, 0), { repeating = true })
bind("SUPER + equal", "Grow width", resize(step, 0), { repeating = true })
bind("SUPER + SHIFT + minus", "Shrink height", resize(0, -step), { repeating = true })
bind("SUPER + SHIFT + equal", "Grow height", resize(0, step), { repeating = true })

-- Mouse: SUPER + arrastar move (esquerdo) ou redimensiona (direito)
bind("SUPER + mouse:272", "Drag window", hl.dsp.window.drag(), { mouse = true })
bind("SUPER + mouse:273", "Resize window (drag)", hl.dsp.window.resize(), { mouse = true })

-- ===== Grupos (abas dentro de uma mesma área) =====
bind("SUPER + G", "Group: toggle", hl.dsp.group.toggle())
bind("SUPER + ALT + G", "Group: remove window", hl.dsp.window.move({ out_of_group = true }))
bind("SUPER + CTRL + Left", "Group: previous tab", hl.dsp.group.prev())
bind("SUPER + CTRL + Right", "Group: next tab", hl.dsp.group.next())
-- entrar no grupo vizinho (Omarchy)
for _, d in ipairs({ { "Left", "l" }, { "Right", "r" }, { "Up", "u" }, { "Down", "d" } }) do
	bind("SUPER + ALT + " .. d[1], "Group: move window into group " .. d[1]:lower(), hl.dsp.window.move({ into_group = d[2] }))
end

-- ===== Workspaces e monitores (veja utils/workspaces.lua) =====
-- SUPER + 1…0: workspace do monitor em foco (a tecla 0 é o 10, jogos)
for slot = 1, 10 do
	local key = slot % 10
	bind("SUPER + " .. key, "Workspace " .. slot, function()
		W.focus(slot)
	end)
	bind("SUPER + ALT + " .. key, "Workspace " .. slot .. " on the other monitor", function()
		W.focus(slot, true)
	end)
	bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. slot, function()
		W.move(slot, true)
	end)
	bind("SUPER + CTRL + " .. key, "Move window to workspace " .. slot .. " (stay)", function()
		W.move(slot, false)
	end)
end

-- m+1: só os workspaces do monitor em foco (Omarchy)
bind({ "SUPER + Tab", "SUPER + mouse_down" }, "Next workspace", hl.dsp.focus({ workspace = "m+1" }))
bind({ "SUPER + SHIFT + Tab", "SUPER + mouse_up" }, "Previous workspace", hl.dsp.focus({ workspace = "m-1" }))
bind("SUPER + CTRL + Tab", "Last workspace", hl.dsp.focus({ workspace = "previous" }))

-- Monitores (O = output)
bind("SUPER + O", "Focus other monitor", hl.dsp.focus({ monitor = "+1" }))
bind("SUPER + CTRL + SHIFT + O", "Move window to other monitor", hl.dsp.window.move({ monitor = "+1" }))
bind("SUPER + CTRL + O", "Move workspace to other monitor", hl.dsp.workspace.move({ monitor = "+1" }))
bind("SUPER + ALT + O", "TV on/off (takes the games workspace)", F.bin .. "tv-toggle")

-- ===== Mídia e volume pelo Noctalia (funcionam com a tela bloqueada) =====
bind("XF86AudioRaiseVolume", "Volume up", ipc("volume-up"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Volume down", ipc("volume-down"), { locked = true, repeating = true })
bind("XF86AudioMute", "Mute", ipc("volume-mute"), { locked = true })
bind("XF86AudioPlay", "Media: play/pause", ipc("media toggle"), { locked = true })
bind("XF86AudioNext", "Media: next", ipc("media next"), { locked = true })
bind("XF86AudioPrev", "Media: previous", ipc("media previous"), { locked = true })

-- ===== Sistema =====
bind("SUPER + CTRL + R", "Reload Hyprland config", hl.dsp.reload_config())
