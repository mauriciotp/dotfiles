-- Opções diversas (misc) e de depuração (debug).
hl.config({
	misc = {
		force_default_wallpaper = 0, -- o wallpaper é do Noctalia
		disable_hyprland_logo = true,
		mouse_move_enables_dpms = true, -- acordar a tela pelo mouse
		key_press_enables_dpms = true, -- ou pelo teclado
		-- se o bloqueio do Noctalia cair, reabrir o Noctalia volta o bloqueio
		-- (sem isso, a sessão fica presa na tela vermelha). Caelestia, H1
		allow_session_lock_restore = true,
		-- o app que pede foco é focado: um link no Discord leva ao Firefox.
		-- Em teste: se puxar o foco no meio de um jogo, volte para false. H2
		focus_on_activate = true,
	},

	-- a barra vermelha de erro da config embaixo, sem cobrir a barra do Noctalia. H10
	debug = { error_position = 1 },
})
