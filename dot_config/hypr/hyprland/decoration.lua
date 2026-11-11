-- Cantos, opacidade, blur e o escurecimento dos workspaces especiais.
local vars = require("variables")

hl.config({
	decoration = {
		rounding = vars.windowRounding,
		inactive_opacity = vars.inactiveOpacity,
		blur = { xray = vars.blurXray, size = vars.blurSize, passes = vars.blurPasses },
		dim_special = vars.dimSpecial,
	},
})
