-- Monitores. Nomes e modos: hyprctl monitors all
-- A tabela "screens" é usada pelo workspaces.lua para saber quem é o principal.
local screens = {
	current = "DP-2", -- Full HD 144 Hz com G-Sync
	tv = "HDMI-A-1", -- LG OLED C4, ligada só para jogar (SUPER+ALT+O, script tv-toggle)
	qhd = nil, -- monitor QHD, quando chegar: ponha aqui o nome da conexão (ex.: "DP-1")
}

-- TV em cima. Em espera ela continua "conectada" pelo HDMI, então começa
-- desativada e o tv-toggle a liga.
hl.monitor({
	output = screens.tv,
	disabled = true,
	-- bitdepth = 10, -- só se precisar: algumas capturas não aceitam 10 bits
})

-- Monitor Full HD embaixo da TV
hl.monitor({
	output = screens.current,
	mode = "1920x1080@144",
	position = "0x1080",
	scale = 1,
})

-- QHD: descomente e ajuste o modo e a posição quando ele chegar
-- hl.monitor({ output = screens.qhd, mode = "2560x1440@165", position = "auto", scale = 1 })

-- Qualquer outra tela (e a VM): resolução preferida, posição automática
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
	-- Jogos XWayland em resolução nativa na TV (sem ampliação borrada)
	xwayland = { force_zero_scaling = true },
	-- VRR (G-Sync) só em tela cheia com conteúdo "game" ou "video" (a regra de
	-- jogos em apps/games.lua marca content = "game"); navegador em tela cheia não pisca
	misc = { vrr = 3 },
	-- HDR: nunca trocar para HDR sozinho em tela cheia
	render = { cm_auto_hdr = 0 },
})

return screens
