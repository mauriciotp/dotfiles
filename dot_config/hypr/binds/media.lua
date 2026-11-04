-- Volume e mídia pelo Noctalia (funcionam com a tela bloqueada)
local L = require("lib")
local bind = L.bind
local function ipc(cmd)
	return hl.dsp.exec_cmd(L.ipc .. cmd)
end

bind("XF86AudioRaiseVolume", "Volume up", ipc("volume-up"), { locked = true, repeating = true })
bind("XF86AudioLowerVolume", "Volume down", ipc("volume-down"), { locked = true, repeating = true })
bind("XF86AudioMute", "Mute", ipc("volume-mute"), { locked = true })
bind("XF86AudioPlay", "Media: play/pause", ipc("media toggle"), { locked = true })
bind("XF86AudioNext", "Media: next", ipc("media next"), { locked = true })
bind("XF86AudioPrev", "Media: previous", ipc("media previous"), { locked = true })
