-- Teclado e mouse. Só o que difere do padrão do Hyprland.
hl.config({
	input = {
		kb_variant = "altgr-intl", -- US com acentos pelo AltGr
		repeat_rate = 40, -- repetições por segundo ao segurar uma tecla
		repeat_delay = 250, -- ms até começar a repetir
		accel_profile = "flat", -- sem aceleração do mouse
		focus_on_close = 2, -- ao fechar uma janela, volta para a última usada (mru). H3
	},

	-- SUPER+roda troca de workspace a cada clique, sem a pausa de 300 ms. H5
	binds = { scroll_event_delay = 0 },
})
