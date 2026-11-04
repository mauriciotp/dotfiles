-- Capturas de tela (Noctalia) e seletor de cor
local L = require("lib")
local mod, bind = L.mod, L.bind
local function ipc(cmd)
	return hl.dsp.exec_cmd(L.ipc .. cmd)
end

bind("Print", "Screenshot: region", ipc("screenshot-region"))
bind("SHIFT + Print", "Screenshot: window", ipc("screenshot-window"))
bind("CTRL + Print", "Screenshot: full screen", ipc("screenshot-fullscreen"))
-- o mesmo do Print, para quando o teclado pede Fn
bind(mod .. " + SHIFT + S", "Screenshot: region", ipc("screenshot-region"))
bind(mod .. " + SHIFT + A", "Screenshot: annotate", ipc("screenshot-annotate"))
bind(mod .. " + SHIFT + C", "Color picker", hl.dsp.exec_cmd("hyprpicker -a"))
