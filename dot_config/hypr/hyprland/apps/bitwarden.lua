-- Popup da extensão do Bitwarden: flutua em 20% × 54% da tela, no centro, e
-- sai preto em gravações e compartilhamentos (Caelestia; no_screen_share do
-- Omarchy). R12, R13, Q1
local F = require("utils.functions")

-- Chrome e derivados: a classe leva o id da extensão e já vale ao abrir
F.window("bitwarden-chromium", ".*nngceckbapebfimnlniiiahkandclblb.*", {
	float = true,
	center = true,
	size = { "monitor_w*0.2", "monitor_h*0.54" },
	no_screen_share = true,
})

-- Firefox: a janela abre como "Mozilla Firefox" e só depois ganha o título do
-- Bitwarden (visto no socket de eventos em 2026-11-13):
--   Mozilla Firefox
--   Extension: (Bitwarden Password Manager) - Bitwarden — Main — Mozilla Firefox
-- Flutuar e tamanho só valem na abertura, então aqui vai por evento, como o
-- "resizer" do Caelestia (execs.lua). É a exceção ao padrão "só regra": quem
-- identifica a janela é um título que chega depois.
-- A regra dinâmica entra com o título: sem animação (a janela não desliza do
-- tiling até o centro) e preta no compartilhamento de tela.
-- O começo do título, escrito uma vez: vira regex para a regra e é comparado
-- como texto no evento.
local TITLE = "Extension: (Bitwarden Password Manager) - Bitwarden"
F.window("bitwarden-firefox", { class = "^firefox$", title = "^" .. F.escape_regex(TITLE) }, { no_anim = true, no_screen_share = true })

hl.on("window.title", function(w)
	if not w or w.floating or w.class ~= "firefox" then
		return
	end
	if (w.title or ""):sub(1, #TITLE) ~= TITLE then
		return
	end
	local sel = "address:" .. w.address
	local size = F.resize_by_screen(20, 54)
	hl.dispatch(hl.dsp.window.float({ window = sel, action = "enable" }))
	if size then
		size.window = sel
		hl.dispatch(hl.dsp.window.resize(size))
	end
	hl.dispatch(hl.dsp.window.center({ window = sel }))
end)
