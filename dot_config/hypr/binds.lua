-- Atalhos. Convenção (padrão do omarchy):
--   SUPER + tecla          → janelas, workspaces, shell
--   SUPER + SHIFT + letra  → apps (letra em inglês: G = Games, R = Record...)
-- Toda bind tem descrição; SUPER+F1 mostra a lista (script ~/.local/bin/keybinds).

local mod = "SUPER"
local ipc = "noctalia msg " -- IPC do Noctalia (docs.noctalia.dev → IPC)
local home = os.getenv("HOME")
-- Caminho absoluto: o PATH do Hyprland não inclui ~/.local/bin
local bin = home .. "/.local/bin/"

-- bind(teclas, descrição, ação, flags opcionais)
local function bind(keys, desc, action, flags)
	flags = flags or {}
	flags.description = desc
	hl.bind(keys, action, flags)
end

-- Abre ou foca um app (~/.local/bin/launch-or-focus)
local function app(class, cmd)
	return hl.dsp.exec_cmd(string.format("%slaunch-or-focus '%s' %s", bin, class, cmd))
end

-- Abre sempre uma janela nova (dentro do uwsm vira unidade do systemd)
local function run(cmd)
	return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

-- ===== Apps =====
bind(mod .. " + Return", "Terminal", run("ghostty"))
bind(mod .. " + ALT + Return", "Terminal with tmux (session main)", run("ghostty -e tmux new-session -A -s main"))
bind(mod .. " + E", "Explorer: files (yazi)", run("ghostty -e yazi"))
bind(mod .. " + B", "Browser", app("^firefox$", "firefox"))
bind(mod .. " + SHIFT + B", "Browser: private window", run("firefox --private-window"))
bind(mod .. " + SHIFT + O", "Obsidian", app("^md\\.obsidian\\.Obsidian$", "obsidian"))
bind(mod .. " + SHIFT + D", "Discord", app("^discord$", "discord"))
bind(mod .. " + SHIFT + G", "Games: Steam", app("^steam$", "steam"))
bind(mod .. " + SHIFT + ALT + G", "Games: Heroic", app("^heroic$", "heroic"))
bind(mod .. " + SHIFT + R", "Record: OBS", app("^com\\.obsproject\\.Studio$", "obs"))
bind(mod .. " + SHIFT + P", "Pods: k9s", app("^com\\.mauricio\\.k9s$", "ghostty --class=com.mauricio.k9s -e k9s"))

-- Música: workspace especial "music". Abre o Spotify se não estiver rodando.
bind(mod .. " + SHIFT + M", "Music: Spotify (toggle)", function()
	hl.dispatch(hl.dsp.exec_cmd("pgrep -x spotify >/dev/null || uwsm app -- spotify-launcher"))
	hl.dispatch(hl.dsp.workspace.toggle_special("music"))
end)

bind(mod .. " + F1", "Keybinds cheatsheet", hl.dsp.exec_cmd(bin .. "keybinds --window"))

-- ===== Noctalia =====
bind(mod .. " + space", "Launcher", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
bind(mod .. " + S", "Control center", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
bind(mod .. " + comma", "Noctalia settings", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
bind("ALT + Tab", "Window switcher", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))
bind("ALT + SHIFT + Tab", "Window switcher (reverse)", hl.dsp.exec_cmd(ipc .. "window-switcher hold reverse"))
bind(mod .. " + V", "Clipboard history", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
bind(mod .. " + period", "Emoji picker", hl.dsp.exec_cmd(ipc .. 'panel-toggle launcher "/emo"'))
bind(mod .. " + CTRL + W", "Wallpaper picker", hl.dsp.exec_cmd(ipc .. 'panel-toggle launcher "/wall"'))
bind(mod .. " + CTRL + SHIFT + D", "Dark/light theme toggle", hl.dsp.exec_cmd(ipc .. "theme-mode-toggle"))
bind(mod .. " + CTRL + N", "Night light toggle", hl.dsp.exec_cmd(ipc .. "nightlight-toggle"))
bind(mod .. " + SHIFT + N", "Notifications: do not disturb", hl.dsp.exec_cmd(ipc .. "notification-dnd-toggle"))
bind(mod .. " + SHIFT + comma", "Notifications: clear", hl.dsp.exec_cmd(ipc .. "notification-clear-active"))
bind(mod .. " + escape", "Lock screen", hl.dsp.exec_cmd(ipc .. "session lock"))
bind(mod .. " + SHIFT + escape", "Session menu", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))

-- ===== Capturas de tela =====
bind("Print", "Screenshot: region", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
bind("SHIFT + Print", "Screenshot: window", hl.dsp.exec_cmd(ipc .. "screenshot-window"))
bind("CTRL + Print", "Screenshot: full screen", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
bind(mod .. " + SHIFT + S", "Screenshot: region", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
bind(mod .. " + SHIFT + A", "Screenshot: annotate", hl.dsp.exec_cmd(ipc .. "screenshot-annotate"))
bind(mod .. " + SHIFT + C", "Color picker", hl.dsp.exec_cmd("hyprpicker -a"))

-- ===== Janelas =====
bind(mod .. " + Q", "Close window", hl.dsp.window.close())
bind(mod .. " + W", "Close window", hl.dsp.window.close())
bind(mod .. " + F", "Fullscreen", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
bind(mod .. " + M", "Maximize", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
bind(mod .. " + T", "Toggle floating", hl.dsp.window.float({ action = "toggle" }))
bind(mod .. " + Y", "Toggle split direction", hl.dsp.layout("togglesplit"))

-- "Pop-out": a janela flutua e fica fixa em todos os workspaces (vídeo, anotações)
bind(mod .. " + P", "Pop-out: float and pin", function()
	hl.dispatch(hl.dsp.window.float({ action = "set" }))
	hl.dispatch(hl.dsp.window.pin())
end)

-- Grupos (abas dentro de uma mesma área)
bind(mod .. " + G", "Group: toggle", hl.dsp.group.toggle())
bind(mod .. " + ALT + G", "Group: remove window", hl.dsp.window.move({ out_of_group = true }))
bind(mod .. " + CTRL + Left", "Group: previous tab", hl.dsp.group.prev())
bind(mod .. " + CTRL + Right", "Group: next tab", hl.dsp.group.next())

-- Foco, mover e trocar: hjkl e setas
local dirs = { h = "left", j = "down", k = "up", l = "right" }
for key, dir in pairs(dirs) do
	bind(mod .. " + " .. key, "Focus " .. dir, hl.dsp.focus({ direction = dir }))
	bind(mod .. " + SHIFT + " .. key, "Move window " .. dir, hl.dsp.window.move({ direction = dir }))
	bind(mod .. " + CTRL + " .. key, "Swap window " .. dir, hl.dsp.window.swap({ direction = dir }))
end
for _, dir in ipairs({ "left", "down", "up", "right" }) do
	bind(mod .. " + " .. dir, "Focus " .. dir, hl.dsp.focus({ direction = dir }))
	bind(mod .. " + SHIFT + " .. dir, "Move window " .. dir, hl.dsp.window.move({ direction = dir }))
end

-- Redimensionar: segure SUPER+ALT+hjkl, ou SUPER+menos/igual na largura
local step = 40
local grow = { h = { -step, 0 }, j = { 0, step }, k = { 0, -step }, l = { step, 0 } }
for key, d in pairs(grow) do
	bind(mod .. " + ALT + " .. key, "Resize window", hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }), { repeating = true })
end
bind(mod .. " + minus", "Shrink width", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
bind(mod .. " + equal", "Grow width", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })

-- ===== Workspaces 1 a 10 (a tecla 0 é o 10) =====
for i = 1, 10 do
	local key = i % 10
	bind(mod .. " + " .. key, "Workspace " .. i, hl.dsp.focus({ workspace = i }))
	bind(mod .. " + SHIFT + " .. key, "Move window to workspace " .. i, hl.dsp.window.move({ workspace = i }))
	bind(mod .. " + CTRL + " .. key, "Move window to workspace " .. i .. " (stay)", hl.dsp.window.move({ workspace = i, follow = false }))
end
bind(mod .. " + Tab", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind(mod .. " + SHIFT + Tab", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))
bind(mod .. " + CTRL + Tab", "Last workspace", hl.dsp.focus({ workspace = "previous" }))
bind(mod .. " + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "e+1" }))
bind(mod .. " + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad: SUPER+crase abre e fecha
bind(mod .. " + grave", "Scratchpad (toggle)", hl.dsp.workspace.toggle_special("scratch"))
bind(mod .. " + SHIFT + grave", "Move window to scratchpad", hl.dsp.window.move({ workspace = "special:scratch" }))

-- ===== Monitores (O = output): monitor embaixo, TV em cima =====
bind(mod .. " + O", "Focus other monitor", hl.dsp.focus({ monitor = "+1" }))
bind(mod .. " + CTRL + SHIFT + O", "Move window to other monitor", hl.dsp.window.move({ monitor = "+1" }))
bind(mod .. " + CTRL + O", "Move workspace to other monitor", hl.dsp.workspace.move({ monitor = "+1" }))
bind(mod .. " + ALT + O", "TV on/off (takes workspace 9)", hl.dsp.exec_cmd(bin .. "tv-toggle"))

-- ===== Sistema =====
bind(mod .. " + CTRL + R", "Reload Hyprland config", hl.dsp.reload_config())
bind(
	mod .. " + SHIFT + E",
	"Exit Hyprland",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Volume e mídia pelo Noctalia (funcionam com a tela bloqueada)
bind("XF86AudioRaiseVolume", "Volume up", hl.dsp.exec_cmd(ipc .. "volume-up"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Volume down", hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, repeating = true })
bind("XF86AudioMute", "Mute", hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true })
bind("XF86AudioPlay", "Media: play/pause", hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
bind("XF86AudioNext", "Media: next", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true })
bind("XF86AudioPrev", "Media: previous", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })

-- Mouse: SUPER + arrastar move (esquerdo) ou redimensiona (direito)
bind(mod .. " + mouse:272", "Drag window", hl.dsp.window.drag(), { mouse = true })
bind(mod .. " + mouse:273", "Resize window (drag)", hl.dsp.window.resize(), { mouse = true })
