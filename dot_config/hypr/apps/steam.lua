-- Steam e Heroic: workspace 8 (stores); no segundo monitor, quando houver.
-- Os jogos vão para o 10 (apps/games.lua).
local L = require("lib")
local W = require("workspaces")

W.app("ws-stores", { class = "^(steam|heroic)$" }, 8)

-- Propriedades do jogo, Configurações e chat são janelas XWayland sem pai
L.single_main_window["steam"] = true

-- lista de amigos alta e estreita
hl.window_rule({
	name = "steam-friends",
	match = { class = "^steam$", title = "^Friends List$" },
	float = true,
	size = { 460, 800 },
})
