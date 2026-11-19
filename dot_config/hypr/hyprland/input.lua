-- Teclado, mouse, cursor e o comportamento dos atalhos.
hl.config({
	input = {
		kb_variant = "altgr-intl", -- US com acentos pelo AltGr
		repeat_rate = 40, -- repetições por segundo ao segurar uma tecla
		repeat_delay = 250, -- ms até começar a repetir
		accel_profile = "flat", -- sem aceleração do mouse
		focus_on_close = 2, -- ao fechar uma janela, volta para a última usada (mru). H3
	},

	binds = {
		-- SUPER+roda troca de workspace a cada clique, sem a pausa de 300 ms. H5
		scroll_event_delay = 0,
		-- trocar de workspace fecha o especial aberto (música, btop ou scratchpad):
		-- evita ficar com um aberto por cima (dots-hyprland, Omarchy). O5
		hide_special_on_workspace_change = true,
	},

	cursor = {
		hotspot_padding = 1, -- Caelestia, dots-hyprland. O6
		hide_on_key_press = true, -- o cursor some enquanto você digita (Omarchy). S1
		-- ao trocar de workspace, o cursor vai para a janela em foco (Omarchy). S2
		warp_on_change_workspace = 1,
	},
})
