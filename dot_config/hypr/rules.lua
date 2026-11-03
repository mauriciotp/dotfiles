-- ===== Workspaces: 9 na TV; o resto no monitor =====
-- persistent mantém o workspace visível no indicador do Noctalia mesmo vazio
hl.workspace_rule({ workspace = "1", monitor = "DP-2", default = true, persistent = true })
for _, ws in ipairs({ "2", "3", "4", "5" }) do
	hl.workspace_rule({ workspace = ws, monitor = "DP-2", persistent = true })
end
for _, ws in ipairs({ "6", "7", "8", "10" }) do
	hl.workspace_rule({ workspace = ws, monitor = "DP-2" })
end
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1", default = true, persistent = true })

-- ===== Noctalia: blur nos painéis, sem a animação de camada do Hyprland =====
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

-- Janela de configurações do Noctalia: flutua com tamanho fixo
hl.window_rule({
	name = "noctalia-settings",
	match = { class = "dev.noctalia.Noctalia" },
	float = true,
	size = { 1080, 920 },
})

-- ===== Regras gerais =====
-- Ignora pedidos de "maximizar" dos apps (atrapalham o tiling)
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Vídeo ou jogo em tela cheia impede o bloqueio e o desligamento das telas
hl.window_rule({ name = "idle-fullscreen", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Diálogos de arquivo e janelas utilitárias: flutuam, centralizados
hl.window_rule({
	name = "float-dialogs",
	match = { title = "^(Open File|Open Folder|Save As|Save File|File Operation Progress)$" },
	float = true,
	center = true,
})
hl.window_rule({
	name = "float-utils",
	match = { class = "^(xdg-desktop-portal-gtk|pinentry-.*|nm-connection-editor)$" },
	float = true,
	center = true,
})

-- pinentry (senha do GPG) não pode perder o foco
hl.window_rule({ name = "pinentry-focus", match = { class = "^pinentry-.*$" }, stay_focused = true })

-- Steam: lista de amigos e configurações flutuam
hl.window_rule({
	name = "steam-floats",
	match = { class = "^steam$", title = "^(Friends List|Steam Settings|Settings)$" },
	float = true,
})

-- Picture-in-picture do Firefox: flutua, fixa em todos os workspaces e mantém a proporção
hl.window_rule({
	name = "pip",
	match = { title = "^(Picture-in-Picture)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
})

-- ===== Cada app no seu workspace (silent: não rouba o foco) =====
hl.window_rule({ name = "ws-browser", match = { class = "^(firefox)$" }, workspace = "2 silent" })
hl.window_rule({ name = "ws-chat", match = { class = "^(discord|vesktop)$" }, workspace = "3 silent" })
hl.window_rule({ name = "ws-media", match = { class = "^[Ss]potify$" }, workspace = "4 silent" })
hl.window_rule({
	name = "obsidian",
	match = { class = "^md.obsidian.Obsidian$" },
	workspace = "4 silent",
})
hl.window_rule({ name = "ws-stores", match = { class = "^(steam|heroic)$" }, workspace = "8 silent" })
