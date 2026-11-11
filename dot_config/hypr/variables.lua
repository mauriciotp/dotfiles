-- Apps, telas e valores usados pelos outros arquivos (formato do Caelestia).
-- Só entra aqui o que difere do padrão do Hyprland (hyprctl descriptions).
-- As teclas NÃO ficam aqui: cada uma está escrita na própria bind (hyprland/keybinds.lua).
return {
	-- ===== Telas =====
	-- Nomes e modos: hyprctl monitors all
	screens = {
		current = "DP-2", -- Full HD 144 Hz com G-Sync
		tv = "HDMI-A-1", -- LG OLED C4, ligada só para jogar (SUPER+ALT+O, script tv-toggle)
		qhd = nil, -- monitor QHD, quando chegar: ponha aqui o nome da conexão (ex.: "DP-1")
	},

	-- ===== Apps =====
	terminal = "ghostty",
	tmuxTerminal = "ghostty -e tmux new-session -A -s main",
	browser = "firefox",
	privateBrowser = "firefox --private-window",
	fileExplorer = "ghostty -e yazi",
	editor = "ghostty -e nvim",
	k9s = "ghostty --class=com.mauricio.k9s -e k9s",
	heroic = "heroic",
	obs = "obs",

	-- ===== Aparência =====
	windowGapsOut = 10, -- doc do Noctalia
	windowBorderSize = 2,
	windowRounding = 12,
	inactiveOpacity = 0.95,
	blurXray = true, -- doc do Noctalia (as três do blur)
	blurSize = 3,
	blurPasses = 2,
	dimSpecial = 0.6, -- escurece o que está embaixo de um workspace especial aberto (Omarchy)

	-- ===== Diversos =====
	resizeStep = 40, -- pixels por toque ao redimensionar pelo teclado
	-- a tecla do scratchpad fecha o especial aberto, seja qual for, em vez de
	-- abrir o scratchpad por cima dele (Caelestia)
	specialWsCloseAny = true,

	-- ===== Workspaces especiais (formato do Caelestia, sem o cli.json) =====
	-- categoria → apps. Cada app:
	--   classes  as classes exatas da janela (hyprctl clients); viram a regra
	--            que manda a janela para o especial (hyprland/rules.lua)
	--   command  abre o app quando a tecla do especial é apertada e ele não está rodando
	--   move     traz para o especial a janela que estiver em outro workspace
	-- O scratchpad ("scratch") não está aqui: começa vazio e você manda as janelas.
	-- Especial novo: uma entrada aqui e uma tecla em hyprland/keybinds.lua.
	toggles = {
		music = {
			spotify = { classes = { "Spotify", "spotify" }, command = "spotify-launcher", move = true },
		},
		communication = {
			discord = { classes = { "discord" }, command = "discord", move = true },
			vesktop = { classes = { "vesktop" }, move = true },
		},
		sysmon = {
			btop = { classes = { "com.mauricio.btop" }, command = "ghostty --class=com.mauricio.btop -e btop" },
		},
		notes = {
			obsidian = { classes = { "md.obsidian.Obsidian" }, command = "obsidian", move = true },
		},
	},
}
