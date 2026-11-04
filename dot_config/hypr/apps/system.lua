-- Regras gerais e janelas do sistema (portal, senha, compartilhamento de tela)
local L = require("lib")

-- Ignora pedidos de "maximizar" dos apps (atrapalham o tiling)
hl.window_rule({ name = "suppress-maximize", match = { class = ".*" }, suppress_event = "maximize" })

-- Vídeo ou jogo em tela cheia impede o bloqueio e o desligamento das telas
hl.window_rule({ name = "idle-fullscreen", match = { class = ".*" }, idle_inhibit = "fullscreen" })

-- Popups vazios do XWayland (menus da Steam etc.) não roubam o foco (Omarchy)
hl.window_rule({
	name = "xwayland-empty-popups",
	match = { class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	no_focus = true,
})

-- ===== Janelas flutuantes =====
-- O Hyprland já flutua sozinho janelas com janela-pai ou de tamanho fixo
-- (e diálogos X11). Aqui ficam só as que deveriam flutuar mas não avisam.
-- Para saber se uma regra sobra: comente, recarregue (SUPER+CTRL+R), abra a janela.
L.medium = { "monitor_w*0.6", "monitor_h*0.75" }

-- L.float(nome, match, tamanho): flutua centralizada
function L.float(nome, match, size)
	hl.window_rule({ name = "float-" .. nome, match = match, float = true, center = true, size = size })
end

-- senha do GPG/SSH (pinentry-gtk): flutua e não perde o foco
L.float("pinentry", { class = "^pinentry-.*$" }, { 520, 220 })
hl.window_rule({ name = "pinentry-focus", match = { class = "^pinentry-.*$" }, stay_focused = true })
-- seletor de arquivos do portal, para apps que não informam a janela-pai
L.float("portal", { class = "^xdg-desktop-portal-gtk$" }, L.medium)
-- escolher a tela ao compartilhar (xdg-desktop-portal-hyprland)
L.float("share-picker", { class = "^hyprland-share-picker$" }, { 640, 480 })

-- ===== Apps que abrem janelas extras sem declarar a janela-pai =====
-- A primeira janela do app fica no tiling; as outras flutuam centralizadas.
-- A lista L.single_main_window é preenchida nos arquivos de cada app.
hl.on("window.open", function(w)
	if not L.single_main_window[w.class] or w.floating then
		return
	end
	-- só conta janelas do mesmo app no tiling: splash e janelas flutuantes não contam
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
