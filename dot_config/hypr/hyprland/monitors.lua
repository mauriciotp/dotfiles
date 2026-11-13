-- Monitores. Os nomes das conexões ficam em variables.lua (screens);
-- o utils/workspaces.lua usa a mesma tabela para saber quem é o principal.
local screens = require("variables").screens

-- TV em cima. Em espera ela continua "conectada" pelo HDMI, então começa
-- desativada e o tv-toggle a liga. Num reload da config, se ela já estiver
-- ligada, continua ligada no modo de agora (sem isto, o reload a desligava).
local tv
for _, m in ipairs(hl.get_monitors() or {}) do
	if m.name == screens.tv then
		tv = m
	end
end
if tv then
	hl.monitor({
		output = screens.tv,
		mode = string.format("%dx%d@%.3f", tv.width, tv.height, tv.refresh_rate or 60),
		position = "0x0",
		scale = tv.scale,
	})
else
	hl.monitor({
		output = screens.tv,
		disabled = true,
		-- bitdepth = 10, -- só se precisar: algumas capturas não aceitam 10 bits
	})
end

-- Monitor Full HD embaixo da TV
hl.monitor({
	output = screens.current,
	mode = "1920x1080@144",
	position = "0x1080",
	scale = 1,
	-- HDR só na TV: este monitor anuncia HDR, mas é da classe DisplayHDR 400
	-- (400 nits pelo EDID), e a ArchWiki avisa que telas assim dão HDR ruim.
	-- Com -1, o Hyprland nunca liga HDR aqui, nem para um jogo pedindo
	supports_hdr = -1,
})

-- QHD: descomente e ajuste o modo e a posição quando ele chegar
-- hl.monitor({ output = screens.qhd, mode = "2560x1440@165", position = "auto", scale = 1 })

-- Qualquer outra tela (e a VM): resolução preferida, posição automática
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

hl.config({
	-- Jogos XWayland em resolução nativa na TV (sem ampliação borrada)
	xwayland = { force_zero_scaling = true },
	-- VRR (G-Sync) só em tela cheia com conteúdo "game" ou "video" (as regras de
	-- hyprland/apps/games.lua marcam content = "game"); navegador em tela cheia não pisca
	misc = { vrr = 3 },
	-- HDR: a tela troca para HDR sozinha quando um jogo HDR fica em tela cheia, e
	-- volta ao SDR ao sair (o desktop continua em SDR). Os jogos pedem HDR pelo
	-- script ~/.local/bin/hdr (GE-Proton) ou pelo gamescope com --hdr-enabled
	render = { cm_auto_hdr = 1 },
	-- o gamescope espera a tela já em HDR antes de abrir; sem isto, a troca
	-- automática pode dar tela branca e piscar (doc do Hyprland, quirks)
	quirks = { prefer_hdr = 2 },
})
