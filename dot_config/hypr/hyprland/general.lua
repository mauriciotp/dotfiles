-- Margens, tearing, o layout dwindle e o arrastar das janelas.
-- A borda fica no padrão do Hyprland, 1 px (Caelestia e dots-hyprland usam o mesmo). O2
local vars = require("variables")

hl.config({
	general = {
		gaps_out = vars.windowGapsOut,
		-- espaço entre um workspace e outro na animação de troca (Caelestia). O1
		gaps_workspaces = vars.workspaceGaps,
		-- cores das bordas: vêm do tema do Noctalia (noctalia.lua, gerado pelo template)
		allow_tearing = true, -- chave geral; vale só com a regra immediate (hyprland/apps/games.lua)
		resize_on_border = true, -- redimensionar arrastando a borda (dots-hyprland, Omarchy). O7
		-- janela flutuante gruda nas bordas da tela e nas outras janelas (dots-hyprland). O8
		snap = { enabled = true },
	},

	dwindle = {
		preserve_split = true,
		-- janela nova sempre à direita ou embaixo; no padrão, o lado depende de
		-- onde o mouse está (Omarchy). S3
		force_split = 2,
	},
})
