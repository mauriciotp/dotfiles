-- Regras de janela que valem para mais de um app: regras gerais, tags e
-- workspaces. O que é de um app só fica em hyprland/apps/.
local F = require("utils.functions")
local W = require("utils.workspaces")
local window, tagged_rule, create_tag = F.window, F.tagged_rule, F.create_tag

-- ===== Regras gerais =====

-- Ignora pedidos de "maximizar" dos apps (atrapalham o tiling)
window("suppress-maximize", ".*", { suppress_event = "maximize" })

-- Vídeo ou jogo em tela cheia impede o bloqueio e o desligamento das telas
window("idle-fullscreen", ".*", { idle_inhibit = "fullscreen" })

-- Popups vazios do XWayland (menus da Steam etc.) não roubam o foco (Omarchy)
window(
	"xwayland-empty-popups",
	{ class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	{ no_focus = true }
)

-- ===== Janelas do sistema =====
-- O Hyprland já flutua sozinho janelas com janela-pai ou de tamanho fixo
-- (e diálogos X11). Aqui ficam só as que deveriam flutuar mas não avisam.
-- Para saber se uma regra sobra: comente, recarregue (SUPER+CTRL+R), abra a janela.

-- senha do GPG/SSH (pinentry-gtk): flutua e não perde o foco
window("pinentry", "^pinentry-.*$", { float = true, center = true, size = { 520, 220 }, stay_focused = true })
-- escolher a tela ao compartilhar (xdg-desktop-portal-hyprland)
window("share-picker", "^hyprland-share-picker$", { float = true, center = true, size = { 640, 480 } })

-- ===== Listas por tag =====
-- Para um app ganhar o comportamento de uma tag, acrescente a classe dele na
-- lista (como o hyprctl clients mostra, em regex).

-- flutua centralizada em 60% × 75% da tela
tagged_rule("float_60_75", {
	"^xdg-desktop-portal-gtk$", -- seletor de arquivos do portal, para apps que não informam a janela-pai
	"^com\\.mauricio\\.keybinds$", -- cola de atalhos (SUPER+F1): janela comum do Ghostty
}, "class")

-- workspace especial "music" (SUPER+SHIFT+M abre e fecha por cima de tudo).
-- O spotify-launcher roda via XWayland e a janela já nasce com a classe "Spotify".
-- Se um dia mudar para Wayland nativo e nascer sem classe, troque esta linha por
-- tagged_rule("music_player", { { initial_title = "^Spotify" } })
tagged_rule("music_player", { "^[Ss]potify$" }, "class")

-- ===== Definição das tags =====
-- Sempre depois das listas: a regra da tag só enxerga as tags já dadas acima.
create_tag("float_60_75", { float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.75" } })
create_tag("music_player", { workspace = "special:music silent" })

-- ===== Apps que abrem janelas extras sem declarar a janela-pai =====
-- A primeira janela do app fica no tiling; as outras flutuam centralizadas.
-- A lista F.single_main_window é preenchida nos arquivos de cada app
-- (hyprland/apps/): true, ou uma função que recebe a janela e diz se a regra
-- vale para ela (e se ela conta como janela principal: o Big Picture não conta).
hl.on("window.open", function(w)
	local entry = F.single_main_window[w.class]
	if not entry or w.floating or (type(entry) == "function" and not entry(w)) then
		return
	end
	-- só conta janelas do mesmo app no tiling: splash e janelas flutuantes não contam
	for _, other in ipairs(hl.get_windows()) do
		local counts = type(entry) ~= "function" or entry(other)
		if counts and other.address ~= w.address and other.class == w.class and other.mapped and not other.floating then
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

-- ===== Workspace fixo por app =====
-- W.app(nome, match, número): no segundo monitor, quando houver, os números
-- 3, 5, 6 e 8 viram 13, 15, 16 e 18 (utils/workspaces.lua).
-- Os jogos (workspace 10) ficam em hyprland/apps/games.lua.
W.app("ws-web", { class = "^firefox$" }, 2)
W.app("ws-chat", { class = "^(discord|vesktop)$" }, 3)
W.app("ws-notes", { class = "^md\\.obsidian\\.Obsidian$" }, 4)
W.app("ws-media", { class = "^com\\.obsproject\\.Studio$" }, 5)
W.app("ws-tools", { class = "^com\\.mauricio\\.k9s$" }, 6) -- Ghostty com classe própria (SUPER+SHIFT+P)
W.app("ws-stores", { class = "^(steam|heroic)$" }, 8)
