-- Atalhos de apps. Convenção do Omarchy:
--   SUPER + SHIFT + letra        → app (letra em inglês: B = Browser, F = Files, G = Games...)
--   SUPER + SHIFT + ALT + letra  → variante do mesmo app
local L = require("lib")
local mod, bind, app, run = L.mod, L.bind, L.app, L.run

bind(mod .. " + Return", "Terminal", run("ghostty"))
bind(mod .. " + ALT + Return", "Terminal with tmux (session main)", run("ghostty -e tmux new-session -A -s main"))
bind(mod .. " + SHIFT + B", "Browser", app("^firefox$", "firefox"))
bind(mod .. " + SHIFT + ALT + B", "Browser: private window", run("firefox --private-window"))
bind(mod .. " + SHIFT + F", "Files: yazi", run("ghostty -e yazi"))
bind(mod .. " + SHIFT + N", "Neovim", run("ghostty -e nvim"))
bind(mod .. " + SHIFT + O", "Obsidian", app("^md\\.obsidian\\.Obsidian$", "obsidian"))
bind(mod .. " + SHIFT + D", "Discord", app("^discord$", "discord"))
bind(mod .. " + SHIFT + G", "Games: Steam", app("^steam$", "steam"))
bind(mod .. " + SHIFT + ALT + G", "Games: Heroic", app("^heroic$", "heroic"))
-- modo console: Steam no Big Picture dentro do gamescope, na TV (~/.local/bin/steam-console)
bind(mod .. " + CTRL + SHIFT + G", "Games: Steam console mode on/off (gamescope)", run(L.bin .. "steam-console"))
-- variante: no monitor, com a TV desligada (alguém usando os apps da TV)
bind(mod .. " + CTRL + SHIFT + ALT + G", "Games: Steam console mode on the monitor", run(L.bin .. "steam-console --monitor"))
bind(mod .. " + SHIFT + R", "Record: OBS", app("^com\\.obsproject\\.Studio$", "obs"))
bind(mod .. " + SHIFT + P", "Pods: k9s", app("^com\\.mauricio\\.k9s$", "ghostty --class=com.mauricio.k9s -e k9s"))

-- Música: workspace especial "music". Abre o Spotify se não estiver rodando.
bind(mod .. " + SHIFT + M", "Music: Spotify (toggle)", function()
	hl.dispatch(hl.dsp.exec_cmd("pgrep -x spotify >/dev/null || uwsm app -- spotify-launcher"))
	hl.dispatch(hl.dsp.workspace.toggle_special("music"))
end)

bind(mod .. " + F1", "Keybinds cheatsheet", hl.dsp.exec_cmd(L.bin .. "keybinds --window"))
