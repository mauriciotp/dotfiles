-- Jogos: Steam (steam_app_*), gamescope, jogos do Heroic/Lutris pelo Proton
-- (*.exe) e emuladores. Vão para o workspace 10, que fica na TV quando ela está
-- ligada pelo SUPER+ALT+O e no monitor quando não (workspaces.lua).
local W = require("workspaces")

-- Emuladores: a janela inteira conta como jogo (a lista de jogos também vai
-- para o 10). A regra diferencia maiúsculas: no X11 o Lichii se chama "Lichii"
-- (visto no hyprctl clients); no Wayland, pelo app id do .desktop.
-- Recomps (jogos recompilados para PC): a classe é o app id da janela.
-- Emulador ou recomp novo: acrescente a classe aqui, exatamente como o hyprctl clients mostra.
local emulators = {
	"[Ll]ichii",
	"io\\.github\\.zortos293\\.lichii",
	"io\\.github\\.NotRexed\\.Hookshot", -- Zelda: Ocarina of Time (Hookshot)
	"es-de", -- ES-DE: o frontend abre no 10, junto com os jogos que ele abre
}

local games = "^(steam_app_.*|gamescope|.*\\.exe|" .. table.concat(emulators, "|") .. ")$"

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
