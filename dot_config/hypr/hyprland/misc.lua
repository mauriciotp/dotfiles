-- Opções diversas (misc) e de depuração (debug).
hl.config({
	misc = {
		force_default_wallpaper = 0, -- o wallpaper é do Noctalia
		disable_hyprland_logo = true,
		disable_splash_rendering = true, -- sem o texto de boas-vindas no fundo (Omarchy). S5
		disable_scale_notification = true, -- sem o aviso ao mudar a escala de um monitor (Omarchy). S5
		mouse_move_enables_dpms = true, -- acordar a tela pelo mouse
		key_press_enables_dpms = true, -- ou pelo teclado
		-- se o bloqueio do Noctalia cair, reabrir o Noctalia volta o bloqueio
		-- (sem isso, a sessão fica presa na tela vermelha). Caelestia, H1
		allow_session_lock_restore = true,
		-- o bloqueio mostra o fundo em vez de preto enquanto o Noctalia desenha
		-- a tela de bloqueio (Caelestia, dots-hyprland). O4
		session_lock_xray = true,
		-- o app que pede foco é focado: um link no Discord leva ao Firefox.
		-- O Discord não pode pedir foco (hyprland/apps/discord.lua). H2, Q7
		focus_on_activate = true,
		-- sem som no "bip" do terminal. Opção nova da 0.57: com a guarda, um
		-- Hyprland mais antigo ainda rodando (no meio de uma atualização) não dá
		-- erro de config (Omarchy, 2026-11-08). S4, T9
		bell_sound = hl.get_config("misc.bell_sound") ~= nil and "none" or nil,
	},

	-- a barra vermelha de erro da config embaixo, sem cobrir a barra do Noctalia. H10
	debug = { error_position = 1 },
})
