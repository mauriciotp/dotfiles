-- Atalhos de janelas: fechar, tela cheia, foco, mover, redimensionar, grupos
local L = require("lib")
local mod, bind = L.mod, L.bind

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

-- Redimensionar: segure SUPER+ALT+hjkl; SUPER+menos/igual na largura,
-- SUPER+SHIFT+menos/igual na altura (Omarchy)
local step = 40
local grow = { h = { -step, 0 }, j = { 0, step }, k = { 0, -step }, l = { step, 0 } }
for key, d in pairs(grow) do
	bind(mod .. " + ALT + " .. key, "Resize window", hl.dsp.window.resize({ x = d[1], y = d[2], relative = true }), { repeating = true })
end
local function resize(x, y)
	return hl.dsp.window.resize({ x = x, y = y, relative = true })
end
bind(mod .. " + minus", "Shrink width", resize(-step, 0), { repeating = true })
bind(mod .. " + equal", "Grow width", resize(step, 0), { repeating = true })
bind(mod .. " + SHIFT + minus", "Shrink height", resize(0, -step), { repeating = true })
bind(mod .. " + SHIFT + equal", "Grow height", resize(0, step), { repeating = true })

-- Grupos (abas dentro de uma mesma área)
bind(mod .. " + G", "Group: toggle", hl.dsp.group.toggle())
bind(mod .. " + ALT + G", "Group: remove window", hl.dsp.window.move({ out_of_group = true }))
bind(mod .. " + CTRL + Left", "Group: previous tab", hl.dsp.group.prev())
bind(mod .. " + CTRL + Right", "Group: next tab", hl.dsp.group.next())
-- entrar no grupo vizinho (Omarchy)
for _, d in ipairs({ { "Left", "l" }, { "Right", "r" }, { "Up", "u" }, { "Down", "d" } }) do
	bind(mod .. " + ALT + " .. d[1], "Group: move window into group " .. d[1]:lower(), hl.dsp.window.move({ into_group = d[2] }))
end

-- Mouse: SUPER + arrastar move (esquerdo) ou redimensiona (direito)
bind(mod .. " + mouse:272", "Drag window", hl.dsp.window.drag(), { mouse = true })
bind(mod .. " + mouse:273", "Resize window (drag)", hl.dsp.window.resize(), { mouse = true })

bind(mod .. " + CTRL + R", "Reload Hyprland config", hl.dsp.reload_config())
