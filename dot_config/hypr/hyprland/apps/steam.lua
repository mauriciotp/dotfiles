-- Steam: janelas extras, lista de amigos e Big Picture.
-- O Big Picture vai para o 10 da tela onde abriu: a tela onde você clicou no
-- botão da Steam, ou a que o steam-bigpicture pôs em foco.
local F = require("utils.functions")
local W = require("utils.workspaces")

local function is_big_picture(w)
	return w and w.class == "steam" and w.title ~= nil and w.title:find("Big Picture", 1, true) ~= nil
end

-- Propriedades do jogo, Configurações e chat são janelas XWayland sem pai:
-- flutuam (hyprland/rules.lua). O Big Picture fica de fora.
F.single_main_window["steam"] = function(w)
	return not is_big_picture(w)
end

-- lista de amigos alta e estreita
F.window("steam-friends", { class = "^steam$", title = "^Friends List$" }, { float = true, size = { 460, 800 } })

-- Big Picture: vai para o 10 e fica em tela cheia, como um console.
-- Por evento, e não por regra: as regras só olham o título inicial (wiki,
-- Window Rules), e a janela pode nascer só como "Steam".
-- Age só quando a janela vira Big Picture (o título muda de novo quando um jogo
-- abre). E nunca toma a tela cheia de outra janela no 10: tirava a do jogo (lento).
local was_big_picture = {}

local function other_fullscreen_on(id, w)
	for _, other in ipairs(hl.get_windows()) do
		if other.address ~= w.address and other.workspace and other.workspace.id == id and (other.fullscreen or 0) ~= 0 then
			return true
		end
	end
	return false
end

-- Tela do Big Picture: a que o steam-bigpicture pediu (recado de até 30 s, em
-- BIGPICTURE_TARGET), porque a Steam pode reaproveitar a própria janela, que
-- está em outra tela; sem recado (o botão da Steam), a tela da janela
local function target_monitor(w)
	local hint = rawget(_G, "BIGPICTURE_TARGET")
	BIGPICTURE_TARGET = nil
	if type(hint) == "table" and hint.at and os.time() - hint.at <= 30 then
		for _, m in ipairs(hl.get_monitors()) do
			if m.name == hint.name then
				return m
			end
		end
	end
	return w.monitor
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
	local id = W.id(W.GAME_SLOT, target_monitor(w))
	if not (w.workspace and w.workspace.id == id) then
		hl.dispatch(hl.dsp.window.move({ window = sel, workspace = tostring(id), follow = true }))
	end
	if (w.fullscreen or 0) == 0 and not other_fullscreen_on(id, w) then
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
