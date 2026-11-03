-- Nomes e modos: confira com  hyprctl monitors all

-- TV LG OLED C4, HDMI 2.1, em cima
hl.monitor({
	output = "HDMI-A-1",
	disabled = true,
	-- bitdepth = 10,   -- só se precisar; algumas capturas não suportam 10 bits (7.6)
})

-- Monitor Full HD com G-Sync, DisplayPort, embaixo da TV
hl.monitor({
	output = "DP-2",
	mode = "1920x1080@144",
	position = "0x1080",
	scale = 1,
})

-- Qualquer outra tela (e a VM): resolução preferida, posição automática
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
	-- Jogos XWayland em resolução nativa na TV (sem ampliação borrada)
	xwayland = { force_zero_scaling = true },
	-- VRR (G-Sync) nas duas telas, só em tela cheia
	misc = { vrr = 2 },
	-- HDR desligado: nunca trocar para HDR sozinho em tela cheia (7.7)
	render = { cm_auto_hdr = 0 },
})
