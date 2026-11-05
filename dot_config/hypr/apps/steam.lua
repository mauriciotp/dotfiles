-- Steam e Heroic: workspace 8 (stores); no segundo monitor, quando houver.
-- Os jogos e o Big Picture vão para o 10 (na TV quando ela está ligada).
local L = require("lib")
local W = require("workspaces")

W.app("ws-stores", { class = "^(steam|heroic)$" }, 8)

local function is_big_picture(w)
	return w and w.class == "steam" and w.title ~= nil and w.title:find("Big Picture", 1, true) ~= nil
end

-- Propriedades do jogo, Configurações e chat são janelas XWayland sem pai:
-- flutuam (apps/system.lua). O Big Picture fica de fora.
L.single_main_window["steam"] = function(w)
	return not is_big_picture(w)
end

-- lista de amigos alta e estreita
hl.window_rule({
	name = "steam-friends",
	match = { class = "^steam$", title = "^Friends List$" },
	float = true,
	size = { 460, 800 },
})

-- Big Picture: vai para o 10 e fica em tela cheia, como um console.
-- Por evento, e não por regra: as regras só olham o título inicial (wiki,
-- Window Rules), e a janela pode nascer só como "Steam".
-- Age só quando a janela vira Big Picture (o título muda de novo quando um jogo
-- abre). E nunca toma a tela cheia de outra janela no 10: tirava a do jogo (lento).
local was_big_picture = {}

local function other_fullscreen_on_games(w)
	for _, other in ipairs(hl.get_windows()) do
		if other.address ~= w.address and other.workspace and other.workspace.id == W.GAMES and (other.fullscreen or 0) ~= 0 then
			return true
		end
	end
	return false
end

local function send_to_games(w)
	if not w then
		return
	end
	local now = is_big_picture(w)
	local before = was_big_picture[w.address]
	was_big_picture[w.address] = now or nil
	if not now or before then
		return
	end
	local sel = "address:" .. w.address
	if not (w.workspace and w.workspace.id == W.GAMES) then
		hl.dispatch(hl.dsp.window.move({ window = sel, workspace = tostring(W.GAMES), follow = true }))
	end
	if (w.fullscreen or 0) == 0 and not other_fullscreen_on_games(w) then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", window = sel }))
	end
end

hl.on("window.open", send_to_games)
hl.on("window.title", send_to_games)
hl.on("window.close", function(w)
	if w then
		was_big_picture[w.address] = nil
	end
end)
