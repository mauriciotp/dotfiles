local mod = "SUPER"
local terminal = "ghostty"
local files = "ghostty -e yazi"
local browser = "firefox"
local ipc = "noctalia msg " -- comandos do Noctalia (documentação: IPC e Keybinds)
local home = os.getenv("HOME")

-- ===== Programas =====
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + ALT + Return", hl.dsp.exec_cmd(terminal .. " -e tmux new-session -A -s main"))
hl.bind(mod .. " + B", hl.dsp.exec_cmd(browser))
hl.bind(mod .. " + SHIFT + B", hl.dsp.exec_cmd(browser .. " --private-window"))
hl.bind(mod .. " + E", hl.dsp.exec_cmd(files))
hl.bind(mod .. " + SHIFT + O", hl.dsp.exec_cmd("obsidian"))
hl.bind(mod .. " + SHIFT + M", hl.dsp.exec_cmd("spotify-launcher"))
hl.bind(mod .. " + SHIFT + G", hl.dsp.exec_cmd("discord"))
hl.bind(mod .. " + SHIFT + D", hl.dsp.exec_cmd(terminal .. " -e k9s"))

-- ===== Noctalia =====
hl.bind(mod .. " + space", hl.dsp.exec_cmd(ipc .. "panel-toggle launcher"))
hl.bind(mod .. " + S", hl.dsp.exec_cmd(ipc .. "panel-toggle control-center"))
hl.bind(mod .. " + comma", hl.dsp.exec_cmd(ipc .. "settings-toggle"))
hl.bind("ALT + Tab", hl.dsp.exec_cmd(ipc .. "window-switcher hold"))
hl.bind(mod .. " + V", hl.dsp.exec_cmd(ipc .. "panel-toggle clipboard"))
hl.bind(mod .. " + period", hl.dsp.exec_cmd(ipc .. 'panel-toggle launcher "/emo"'))
hl.bind(mod .. " + CTRL + W", hl.dsp.exec_cmd(ipc .. 'panel-toggle launcher "/wall"'))
hl.bind(mod .. " + CTRL + SHIFT + D", hl.dsp.exec_cmd(ipc .. "theme-mode-toggle"))
hl.bind(mod .. " + CTRL + N", hl.dsp.exec_cmd(ipc .. "nightlight-toggle"))
hl.bind(mod .. " + SHIFT + N", hl.dsp.exec_cmd(ipc .. "notification-dnd-toggle"))
hl.bind(mod .. " + SHIFT + comma", hl.dsp.exec_cmd(ipc .. "notification-clear-active"))
hl.bind(mod .. " + escape", hl.dsp.exec_cmd(ipc .. "session lock"))
hl.bind(mod .. " + SHIFT + escape", hl.dsp.exec_cmd(ipc .. "panel-toggle session"))

-- ===== Capturas de tela =====
hl.bind("Print", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(ipc .. "screenshot-window"))
hl.bind("CTRL + Print", hl.dsp.exec_cmd(ipc .. "screenshot-fullscreen"))
hl.bind(mod .. " + SHIFT + S", hl.dsp.exec_cmd(ipc .. "screenshot-region"))
hl.bind(mod .. " + SHIFT + A", hl.dsp.exec_cmd(ipc .. "screenshot-annotate"))
hl.bind(mod .. " + SHIFT + C", hl.dsp.exec_cmd("hyprpicker -a"))

-- ===== Janelas =====
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + W", hl.dsp.window.close())
hl.bind(mod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mod .. " + T", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + Y", hl.dsp.layout("togglesplit"))

-- "Pop-out": a janela flutua e fica fixa em todos os workspaces (vídeo, anotações)
hl.bind(mod .. " + P", function()
	hl.dispatch(hl.dsp.window.float({ action = "set" }))
	hl.dispatch(hl.dsp.window.pin())
end)

-- Grupos (abas dentro de uma mesma área)
hl.bind(mod .. " + G", hl.dsp.group.toggle())
hl.bind(mod .. " + ALT + G", hl.dsp.window.move({ out_of_group = true }))
hl.bind(mod .. " + CTRL + Left", hl.dsp.group.prev())
hl.bind(mod .. " + CTRL + Right", hl.dsp.group.next())

-- Foco, mover e trocar: hjkl e setas
local dirs = { h = "left", j = "down", k = "up", l = "right" }
local arrows = { left = "left", down = "down", up = "up", right = "right" }
for key, dir in pairs(dirs) do
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
	hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.swap({ direction = dir }))
end
for key, dir in pairs(arrows) do
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ direction = dir }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ direction = dir }))
end

-- Redimensionar segurando SUPER+ALT+hjkl, ou SUPER+menos / SUPER+igual na largura
local step = 40
local grow = { h = { -step, 0 }, j = { 0, step }, k = { 0, -step }, l = { step, 0 } }
for key, d in pairs(grow) do
	hl.bind(
		mod .. " + ALT + " .. key,
		hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }),
		{ repeating = true }
	)
end
hl.bind(mod .. " + minus", hl.dsp.window.resize({ x = -step, y = 0, relative = true }), { repeating = true })
hl.bind(mod .. " + equal", hl.dsp.window.resize({ x = step, y = 0, relative = true }), { repeating = true })

-- ===== Workspaces 1 a 10 (a tecla 0 é o 10) =====
for i = 1, 10 do
	local key = i % 10
	hl.bind(mod .. " + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
	hl.bind(mod .. " + CTRL + " .. key, hl.dsp.window.move({ workspace = i, follow = false }))
end
hl.bind(mod .. " + Tab", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + SHIFT + Tab", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mod .. " + CTRL + Tab", hl.dsp.focus({ workspace = "previous" }))
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Scratchpad (SUPER+crase abre e fecha)
hl.bind(mod .. " + grave", hl.dsp.workspace.toggle_special("scratch"))
hl.bind(mod .. " + SHIFT + grave", hl.dsp.window.move({ workspace = "special:scratch" }))

-- Monitor <-> TV
hl.bind(mod .. " + O", hl.dsp.focus({ monitor = "+1" }))
hl.bind(mod .. " + SHIFT + O", hl.dsp.window.move({ monitor = "+1" }))
hl.bind(mod .. " + CTRL + O", hl.dsp.workspace.move({ monitor = "+1" }))
hl.bind(mod .. " + ALT + O", hl.dsp.exec_cmd(home .. "/.local/bin/tv-toggle")) -- 7.6

-- ===== Sistema =====
hl.bind(mod .. " + SHIFT + R", hl.dsp.reload_config())
hl.bind(
	mod .. " + SHIFT + E",
	hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'")
)

-- Volume e mídia pelo Noctalia (funcionam com a tela bloqueada)
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd(ipc .. "volume-up"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd(ipc .. "volume-down"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd(ipc .. "volume-mute"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd(ipc .. "media toggle"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd(ipc .. "media next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd(ipc .. "media previous"), { locked = true })

-- Mouse: SUPER + arrastar move (esquerdo) ou redimensiona (direito)
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
