-- Cantos, opacidade, blur, o escurecimento dos especiais e a barra dos grupos.
local vars = require("variables")

hl.config({
	decoration = {
		rounding = vars.windowRounding,
		inactive_opacity = vars.inactiveOpacity,
		blur = { xray = vars.blurXray, size = vars.blurSize, passes = vars.blurPasses },
		dim_special = vars.dimSpecial,
	},

	-- Barra das abas de um grupo (Omarchy): mais discreta que a do Caelestia.
	-- As cores continuam vindo do Noctalia (noctalia.lua). O10
	group = {
		groupbar = {
			font_size = 12,
			font_family = "monospace",
			font_weight_active = "ultraheavy", -- aba ativa em negrito
			font_weight_inactive = "normal",
			height = 22,
			indicator_height = 1, -- o traço embaixo da aba
			indicator_gap = 5,
			gaps_in = 5,
			gaps_out = 0,
			gradients = true,
			gradient_rounding = 0,
			gradient_round_only_edges = false,
		},
	},
})
