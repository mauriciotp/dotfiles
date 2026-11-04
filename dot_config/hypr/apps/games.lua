-- Jogos: Steam (steam_app_*), gamescope e jogos do Heroic/Lutris pelo Proton (*.exe).
-- Vão para o workspace 10, que fica na TV quando ela está ligada (workspaces.lua).
local games = "^(steam_app_.*|gamescope|.*\\.exe)$"

hl.window_rule({
	name = "games",
	match = { class = games },
	workspace = "10",
	immediate = true, -- tearing permitido (só em tela cheia; chave geral no look.lua)
	content = "game", -- liga o direct scanout automático e o VRR (monitors.lua)
	idle_inhibit = "fullscreen", -- sem bloqueio de tela durante o jogo
})

hl.window_rule({
	name = "games-confine-pointer",
	match = { class = games, fullscreen = true },
	confine_pointer = true, -- o mouse não escapa para o outro monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
