-- Regras de workspaces, janelas e camadas.
-- Ordem importa: as regras que aplicam tags vêm antes das que usam as tags.

-- ===== Workspaces =====
-- Nomes aparecem no indicador do Noctalia. persistent = visível mesmo vazio.
-- Mapa (explicado no vault: Arch Linux/Hyprland/Workspaces):
--   1 dev · 2 web · 3 chat · 4 notes · 5 media · 6 tools · 7 livre
--   8 stores · 9 games (TV ou monitor, via tv-toggle) · 10 livre
local workspaces = {
	{ id = "1", name = "dev", persistent = true, default = true },
	{ id = "2", name = "web", persistent = true },
	{ id = "3", name = "chat", persistent = true },
	{ id = "4", name = "notes", persistent = true },
	{ id = "5", name = "media", persistent = true },
	{ id = "6", name = "tools" },
	{ id = "7", name = "7" },
	{ id = "8", name = "stores" },
	{ id = "10", name = "10" },
}
for _, ws in ipairs(workspaces) do
	hl.workspace_rule({
		workspace = ws.id,
		monitor = "DP-2",
		default_name = ws.name,
		persistent = ws.persistent or false,
		default = ws.default or false,
	})
end
-- 9 fica preso à TV; com a TV desativada o Hyprland o coloca no DP-2 sozinho
hl.workspace_rule({ workspace = "9", monitor = "HDMI-A-1", default_name = "games", persistent = true, default = true })

-- ===== Noctalia: blur nos painéis, sem a animação de camada do Hyprland =====
-- (doc oficial: docs.noctalia.dev → Compositor Settings → Hyprland)
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

-- ===== Regras gerais =====
-- Ignora pedidos de "maximizar" dos apps (atrapalham o tiling)
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Vídeo ou jogo em tela cheia impede o bloqueio e o desligamento das telas
hl.window_rule({ name = "idle-fullscreen", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Popups vazios do XWayland (menus da Steam etc.) não roubam o foco (omarchy)
hl.window_rule({
	name = "xwayland-empty-popups",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

-- ===== Janelas flutuantes =====
-- O Hyprland JÁ flutua sozinho (código: suggestsFloat, v0.57):
--   Wayland: janela que declara uma janela-pai, ou de tamanho fixo
--   X11:     diálogo, modal, transitória, com pai, pop-up ou tamanho fixo
-- Ou seja: diálogos "bem-comportados" (OBS, GTK, Qt) não precisam de regra.
-- Aqui ficam só as exceções: janelas que deveriam flutuar mas não avisam.

-- 1) Janelas avulsas, sem pai, que são diálogos na prática (só apps instalados)
local float_windows = {
	{ class = "^org\\.gnupg\\.pinentry-qt$" }, -- senha do GPG
	{ class = "^(zenity|org\\.gnome\\.Zenity)$" }, -- diálogos de scripts (Steam usa)
	{ class = "^hyprland-share-picker$" }, -- escolher tela ao compartilhar
	{ class = "^xdg-desktop-portal-gtk$" }, -- seletor de arquivos do portal (Firefox, Obsidian...)
	{ class = "^dev\\.noctalia\\.Noctalia$" }, -- Configurações do Noctalia (doc oficial)
	{ class = "^com\\.mauricio\\.keybinds$" }, -- cola de atalhos (SUPER+F1)
	{ class = "^steam$", title = "^(Steam Settings|Settings)$" },
}
for i, m in ipairs(float_windows) do
	hl.window_rule({
		name = "float-" .. i,
		match = m,
		float = true,
		center = true,
		size = { "monitor_w*0.6", "monitor_h*0.75" },
	})
end

-- 2) Apps que abrem janelas secundárias SEM declarar a janela-pai.
-- A primeira janela do app fica no tiling; qualquer janela extra flutua centralizada.
-- Ex.: Obsidian 1.15 abre Settings, Community plugins e Community themes como
-- janelas normais (Electron), com título no mesmo formato da principal; sem isto
-- cada uma vira um tiling novo ("efeito cascata").
-- Só entra app que comprovadamente precisa (veja com: hyprctl clients).
local single_main_window = {
	["md.obsidian.Obsidian"] = true,
	["steam"] = true, -- Propriedades do jogo, Configurações, chat (XWayland, sem pai)
}

hl.on("window.open", function(w)
	if not single_main_window[w.class] or w.floating then
		return
	end
	-- Só conta janelas do mesmo app que estão no tiling: splash screens e
	-- janelas que já flutuam não fazem a principal virar "extra"
	for _, other in ipairs(hl.get_windows()) do
		if other.address ~= w.address and other.class == w.class and other.mapped and not other.floating then
			local m = w.monitor
			local width, height = 1152, 810 -- reserva, se o monitor não vier no evento
			if m then
				width = math.floor(m.width / m.scale * 0.6)
				height = math.floor(m.height / m.scale * 0.75)
			end
			local sel = "address:" .. w.address
			hl.dispatch(hl.dsp.window.float({ window = sel, action = "set" }))
			hl.dispatch(hl.dsp.window.resize({ window = sel, x = width, y = height }))
			hl.dispatch(hl.dsp.window.center({ window = sel }))
			return
		end
	end
end)

-- Steam: lista de amigos alta e estreita
hl.window_rule({
	name = "steam-friends",
	match = { class = "^steam$", title = "^Friends List$" },
	float = true,
	size = { 460, 800 },
})

-- pinentry (senha do GPG) não pode perder o foco
hl.window_rule({ name = "pinentry-focus", match = { class = "^(pinentry-.*|org\\.gnupg\\.pinentry-qt)$" }, stay_focused = true })

-- Picture-in-picture do Firefox: flutua, fixa em todos os workspaces, canto superior direito
hl.window_rule({
	name = "pip",
	match = { title = "^(Picture.?in.?[Pp]icture)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	size = { "monitor_w*0.3", "monitor_h*0.3" },
	move = { "monitor_w-window_w-24", "monitor_h*0.06" },
})

-- ===== Cada app no seu workspace =====
-- Sem "silent": abrir o app leva você até ele (combina com o launch-or-focus)
local app_workspaces = {
	{ "ws-web", { class = "^firefox$" }, "2" },
	{ "ws-chat", { class = "^(discord|vesktop)$" }, "3" },
	{ "ws-notes", { class = "^md\\.obsidian\\.Obsidian$" }, "4" },
	{ "ws-media", { class = "^com\\.obsproject\\.Studio$" }, "5" },
	{ "ws-tools", { class = "^com\\.mauricio\\.(k9s|lazygit)$" }, "6" },
	{ "ws-stores", { class = "^(steam|heroic)$" }, "8" },
}
for _, r in ipairs(app_workspaces) do
	hl.window_rule({ name = r[1], match = r[2], workspace = r[3] })
end

-- Spotify: workspace especial "music" (SUPER+SHIFT+M abre e fecha por cima de tudo).
-- No Wayland o Spotify às vezes nasce sem classe; o título inicial resolve.
hl.window_rule({ name = "music-class", match = { class = "^[Ss]potify$" }, workspace = "special:music silent" })
hl.window_rule({ name = "music-title", match = { initial_title = "^Spotify( Free| Premium)?$" }, workspace = "special:music silent" })
