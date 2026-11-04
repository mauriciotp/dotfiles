-- Aparência. Só o que difere do padrão do Hyprland (hyprctl descriptions).
hl.config({
	general = {
		gaps_out = 10, -- doc do Noctalia
		border_size = 2,
		-- cores das bordas: vêm do tema do Noctalia (noctalia.lua, gerado pelo template)
		allow_tearing = true, -- chave geral; vale só com a regra immediate (apps/games.lua)
	},

	decoration = {
		rounding = 12,
		inactive_opacity = 0.95,
		blur = { xray = true, size = 3, passes = 2 }, -- doc do Noctalia
	},

	dwindle = { preserve_split = true },

	misc = {
		force_default_wallpaper = 0, -- o wallpaper é do Noctalia
		disable_hyprland_logo = true,
		mouse_move_enables_dpms = true, -- acordar a tela pelo mouse
		key_press_enables_dpms = true, -- ou pelo teclado
	},
})

-- Curva de aceleração: começa rápido e assenta suave
hl.curve("smooth", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

-- speed em décimos de segundo (4 = 0,4 s)
hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "smooth" })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "smooth", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth", style = "slide" })
