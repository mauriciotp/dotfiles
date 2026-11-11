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
-- Steam normal; no modo console, sai dele para a janela da Steam no workspace 8
bind(mod .. " + SHIFT + G", "Games: Steam", run(L.bin .. "steam-console --desktop"))
bind(mod .. " + SHIFT + ALT + G", "Games: Heroic", app("^heroic$", "heroic"))
-- modo console: Steam no Big Picture dentro do gamescope, na TV (~/.local/bin/steam-console)
bind(mod .. " + CTRL + SHIFT + G", "Games: Steam console mode on/off (gamescope)", run(L.bin .. "steam-console"))
-- variante: no monitor, com a TV desligada (alguém usando os apps da TV)
bind(mod .. " + CTRL + SHIFT + ALT + G", "Games: Steam console mode on the monitor", run(L.bin .. "steam-console --monitor"))
-- HUD do modo console (mangoapp): começa oculto, e o Shift_R+F12 só funciona
-- com ele visível; no desktop, o HUD do jogo usa o Shift_R+F12. Só com o
-- gamescope aberto: o recado fica na fila do mangoapp até alguém ler, e um
-- toque no desktop mudaria o HUD do próximo modo console
bind(mod .. " + F12", "Games: show/hide the console mode HUD",
	run("sh -c 'pgrep -f \"^gamescope .*--mangoapp\" >/dev/null && exec mangohudctl toggle no_display'"))
bind(mod .. " + SHIFT + R", "Record: OBS", app("^com\\.obsproject\\.Studio$", "obs"))
bind(mod .. " + SHIFT + P", "Pods: k9s", app("^com\\.mauricio\\.k9s$", "ghostty --class=com.mauricio.k9s -e k9s"))

-- Música: workspace especial "music". Abre o Spotify se não estiver rodando.
bind(mod .. " + SHIFT + M", "Music: Spotify (toggle)", function()
	hl.dispatch(hl.dsp.exec_cmd("pgrep -x spotify >/dev/null || uwsm app -- spotify-launcher"))
	hl.dispatch(hl.dsp.workspace.toggle_special("music"))
end)

bind(mod .. " + F1", "Keybinds cheatsheet", hl.dsp.exec_cmd(L.bin .. "keybinds --window"))
