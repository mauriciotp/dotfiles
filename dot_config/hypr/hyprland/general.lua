-- Margens, bordas, tearing e o layout dwindle.
local vars = require("variables")

hl.config({
	general = {
		gaps_out = vars.windowGapsOut,
		border_size = vars.windowBorderSize,
		-- cores das bordas: vêm do tema do Noctalia (noctalia.lua, gerado pelo template)
		allow_tearing = true, -- chave geral; vale só com a regra immediate (hyprland/apps/games.lua)
	},

	dwindle = { preserve_split = true },
})
