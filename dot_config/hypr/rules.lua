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

-- ===== Janelas flutuantes: 3 camadas =====
-- Camada 1: diálogos que o próprio app marca como modais ("Tem certeza?", seletores)
hl.window_rule({ name = "modal", match = { modal = true }, float = true, center = true })

-- Camada 2: tags por tamanho (padrão do omarchy/caelestia).
-- Para fazer um app novo flutuar, basta acrescentar uma linha numa das listas.
local float_tags = {
	-- pequeno: senhas, confirmações, utilitários de sistema
	["float-sm"] = {
		size = { "monitor_w*0.4", "monitor_h*0.5" },
		match = {
			{ class = "^(pinentry-.*|org\\.gnupg\\.pinentry-qt)$" },
			{ class = "^(nm-connection-editor|blueman-manager|hyprland-share-picker|org\\.gnome\\.Zenity|zenity)$" },
			{ title = "^(Authentication Required|Confirm to replace files|File Operation Progress)$" },
		},
	},
	-- médio: seletores de arquivo, preferências, configurações de apps
	["float-md"] = {
		size = { "monitor_w*0.6", "monitor_h*0.7" },
		match = {
			{ class = "^(xdg-desktop-portal-gtk|org\\.freedesktop\\.impl\\.portal\\.desktop\\..*)$" },
			{ class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|qt5ct|qt6ct|nwg-look)$" },
			{ title = "^(Open File|Open Folder|Open Files|Choose Files?|Save As|Save File|Select a File|File Upload).*$" },
			{ title = "^(.* wants to (open|save).*|Properties for .*|Preferences)$" },
			{ class = "^steam$", title = "^(Steam Settings|Settings)$" },
			{ class = "^com\\.mauricio\\.keybinds$" }, -- cola de atalhos (SUPER+F1)
		},
	},
	-- grande: janelas de configuração com muito conteúdo
	["float-lg"] = {
		size = { "monitor_w*0.75", "monitor_h*0.8" },
		match = {
			{ class = "^dev\\.noctalia\\.Noctalia$" }, -- Configurações do Noctalia
		},
	},
}

for tag, def in pairs(float_tags) do
	for i, m in ipairs(def.match) do
		hl.window_rule({ name = tag .. "-" .. i, match = m, tag = "+" .. tag })
	end
	hl.window_rule({ name = tag, match = { tag = tag }, float = true, center = true, size = def.size })
end

-- Camada 3: apps teimosos (janelas secundárias que não se marcam como modais)
-- Apps de "uma janela principal": a primeira janela do app fica no tiling e
-- QUALQUER janela extra (configurações, plugins, temas, propriedades...) flutua
-- centralizada. Resolve o "efeito cascata" sem listar título por título.
-- Ex.: Obsidian 1.15 abre Settings, Community plugins e Community themes como
-- janelas próprias, com títulos no mesmo formato da principal.
-- Para incluir um app: acrescente a classe (veja com: hyprctl clients).
local single_main_window = {
	["md.obsidian.Obsidian"] = true,
	["discord"] = true,
	["com.obsproject.Studio"] = true,
	["heroic"] = true,
	["steam"] = true,
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
