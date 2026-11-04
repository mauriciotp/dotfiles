-- Teclado e mouse. Só o que difere do padrão do Hyprland.
hl.config({
	input = {
		kb_variant = "altgr-intl", -- US com acentos pelo AltGr
		repeat_rate = 40, -- repetições por segundo ao segurar uma tecla
		repeat_delay = 250, -- ms até começar a repetir
		accel_profile = "flat", -- sem aceleração do mouse
	},
})
