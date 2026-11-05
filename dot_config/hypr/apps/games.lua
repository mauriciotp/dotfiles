-- Jogos: Steam (steam_app_*), gamescope e jogos do Heroic/Lutris pelo Proton (*.exe).
-- Vão para o workspace 10, que fica na TV quando ela está ligada (workspaces.lua).
-- Splash, launchers e jogos de emulador: rever no bloco 4 (regras do CachyOS
-- em inbox/Referências/CachyOS/hypr/config/windowrules.lua).
local W = require("workspaces")

local games = "^(steam_app_.*|gamescope|.*\\.exe)$"

hl.window_rule({
	name = "games",
	match = { class = games },
	workspace = tostring(W.GAMES),
	immediate = true, -- tearing permitido (só em tela cheia; chave geral no look.lua)
	content = "game", -- liga o direct scanout automático e o VRR (monitors.lua)
})

hl.window_rule({
	name = "games-confine-pointer",
	match = { class = games, fullscreen = true },
	confine_pointer = true, -- o mouse não escapa para o outro monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
