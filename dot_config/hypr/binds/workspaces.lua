-- Atalhos de workspaces, monitores e do console (veja workspaces.lua)
local L = require("lib")
local W = require("workspaces")
local mod, bind = L.mod, L.bind

-- SUPER + 1…0: workspace do monitor em foco (a tecla 0 é o 10, jogos)
for slot = 1, 10 do
	local key = slot % 10
	bind(mod .. " + " .. key, "Workspace " .. slot, function()
		W.focus(slot)
	end)
	bind(mod .. " + ALT + " .. key, "Workspace " .. slot .. " on the other monitor", function()
		W.focus(slot, true)
	end)
	bind(mod .. " + SHIFT + " .. key, "Move window to workspace " .. slot, function()
		W.move(slot, true)
	end)
	bind(mod .. " + CTRL + " .. key, "Move window to workspace " .. slot .. " (stay)", function()
		W.move(slot, false)
	end)
end

-- m+1: só os workspaces do monitor em foco (Omarchy)
bind(mod .. " + Tab", "Next workspace", hl.dsp.focus({ workspace = "m+1" }))
bind(mod .. " + SHIFT + Tab", "Previous workspace", hl.dsp.focus({ workspace = "m-1" }))
bind(mod .. " + CTRL + Tab", "Last workspace", hl.dsp.focus({ workspace = "previous" }))
bind(mod .. " + mouse_down", "Next workspace", hl.dsp.focus({ workspace = "m+1" }))
bind(mod .. " + mouse_up", "Previous workspace", hl.dsp.focus({ workspace = "m-1" }))

-- Console: terminal com tmux por cima de tudo (apps/terminals.lua)
bind(mod .. " + grave", "Console (toggle)", hl.dsp.workspace.toggle_special("console"))
bind(mod .. " + mouse:275", "Console (toggle)", hl.dsp.workspace.toggle_special("console"))
bind(mod .. " + SHIFT + grave", "Move window to console", hl.dsp.window.move({ workspace = "special:console", follow = false }))

-- Monitores (O = output)
bind(mod .. " + O", "Focus other monitor", hl.dsp.focus({ monitor = "+1" }))
bind(mod .. " + CTRL + SHIFT + O", "Move window to other monitor", hl.dsp.window.move({ monitor = "+1" }))
bind(mod .. " + CTRL + O", "Move workspace to other monitor", hl.dsp.workspace.move({ monitor = "+1" }))
bind(mod .. " + ALT + O", "TV on/off (takes the games workspace)", hl.dsp.exec_cmd(L.bin .. "tv-toggle"))
