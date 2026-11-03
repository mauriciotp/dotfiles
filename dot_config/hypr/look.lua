hl.config({
	general = {
		gaps_in = 5,
		gaps_out = 10,
		border_size = 2,
		-- cores das bordas: vêm do tema do Noctalia (noctalia.lua, gerado pelo template)
		resize_on_border = false,
		allow_tearing = true, -- chave geral; vale só com a regra immediate (11.8)
		layout = "dwindle",
	},

	decoration = {
		rounding = 12,
		rounding_power = 2,
		active_opacity = 1.0,
		inactive_opacity = 0.95,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = 0xee1a1a1a,
		},
		blur = {
			enabled = true,
			xray = true,
			size = 3,
			passes = 2,
			vibrancy = 0.1696,
		},
	},

	animations = { enabled = true },
	dwindle = { preserve_split = true },

	misc = {
		force_default_wallpaper = 0,
		disable_hyprland_logo = true,
		mouse_move_enables_dpms = true,
		key_press_enables_dpms = true,
	},
})

-- Curva de aceleração: começa rápido e assenta suave
hl.curve("suave", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

-- speed em décimos de segundo (4 = 0,4 s)
hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "suave" })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "suave", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "suave" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "suave", style = "slide" })
