-- Regras de jogos (11.8). Carregado por require("games") no hyprland.lua.
-- Steam (steam_app_*), gamescope e jogos do Heroic/Lutris pelo Proton (*.exe)
local jogos = "^(steam_app_.*|gamescope|.*\\.exe)$"

hl.window_rule({
	name = "jogos",
	match = { class = jogos },
	workspace = "9", -- workspace da TV
	immediate = true, -- tearing permitido (só em tela cheia)
	content = "game", -- liga o direct scanout automático
	idle_inhibit = "fullscreen", -- sem bloqueio de tela durante o jogo
})

hl.window_rule({
	name = "jogos-mouse-preso",
	match = { class = jogos, fullscreen = true },
	confine_pointer = true, -- o mouse não escapa para o monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })

-- Workspace 9 para o monitor ou de volta para a TV
hl.bind("SUPER + ALT + M", hl.dsp.workspace.move({ workspace = "9", monitor = "DP-2" }), { description = "Games workspace to monitor" })
hl.bind("SUPER + ALT + T", hl.dsp.workspace.move({ workspace = "9", monitor = "HDMI-A-1" }), { description = "Games workspace to TV" })
