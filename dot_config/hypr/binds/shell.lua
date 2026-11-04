-- Atalhos do Noctalia (launcher, painéis, notificações, sessão)
local L = require("lib")
local mod, bind = L.mod, L.bind
local function ipc(cmd)
	return hl.dsp.exec_cmd(L.ipc .. cmd)
end

bind(mod .. " + space", "Launcher", ipc("panel-toggle launcher"))
bind(mod .. " + S", "Control center", ipc("panel-toggle control-center"))
bind(mod .. " + comma", "Noctalia settings", ipc("settings-toggle"))
bind("ALT + Tab", "Window switcher", ipc("window-switcher hold"))
bind("ALT + SHIFT + Tab", "Window switcher (reverse)", ipc("window-switcher hold reverse"))
bind(mod .. " + V", "Clipboard history", ipc("panel-toggle clipboard"))
bind(mod .. " + period", "Emoji picker", ipc('panel-toggle launcher "/emo"'))
bind(mod .. " + CTRL + W", "Wallpaper picker", ipc('panel-toggle launcher "/wall"'))
bind(mod .. " + CTRL + SHIFT + D", "Dark/light theme toggle", ipc("theme-mode-toggle"))
bind(mod .. " + CTRL + N", "Night light toggle", ipc("nightlight-toggle"))

-- Notificações: SUPER + vírgula e variantes
bind(mod .. " + SHIFT + comma", "Notifications: clear", ipc("notification-clear-active"))
bind(mod .. " + CTRL + comma", "Notifications: do not disturb", ipc("notification-dnd-toggle"))

-- Sessão: para sair do Hyprland, use o menu (pede confirmação)
bind(mod .. " + escape", "Lock screen", ipc("session lock"))
bind(mod .. " + SHIFT + escape", "Session menu", ipc("panel-toggle session"))
