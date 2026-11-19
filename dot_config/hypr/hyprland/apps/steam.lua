-- Steam: janelas extras flutuando, lista de amigos e Big Picture em tela cheia. O Big Picture fica no workspace onde abriu; pedido
-- pelo steam-bigpicture para outra tela, vai para o workspace que ela mostra.
local F = require("utils.functions")

local function is_big_picture(w)
	return w and w.class == "steam" and w.title ~= nil and w.title:find("Big Picture", 1, true) ~= nil
end

-- Janelas extras (amigos, configurações, jogos da biblioteca) flutuam no tamanho
-- que a Steam pede; a principal ("Steam") volta ao tiling. A Steam às vezes nasce
-- flutuando sozinha (thinglab.org, 2026-01). Tags definidas em hyprland/tags.lua.
F.tagged_rule("float", { "^steam$" }, "class")
F.tagged_rule("tile", { { class = "^steam$", initial_title = "^Steam$" } })

-- lista de amigos alta e estreita (Omarchy)
F.window("steam-friends", { class = "^steam$", title = "^Friends List$" }, { size = { 460, 800 } })

-- Big Picture: fica em tela cheia, como um console.
-- Por evento, e não por regra: as regras só olham o título inicial (wiki,
-- Window Rules), e a janela pode nascer só como "Steam".
-- Age só quando a janela vira Big Picture (o título muda de novo quando um jogo
-- abre). E nunca toma a tela cheia de outra janela do mesmo workspace: tirava
-- a do jogo (lento).
local was_big_picture = {}

local function other_fullscreen_on(id, w)
	for _, other in ipairs(hl.get_windows() or {}) do
		if other.address ~= w.address and other.workspace and other.workspace.id == id and (other.fullscreen or 0) ~= 0 then
			return true
		end
	end
	return false
end

-- Workspace pedido pelo steam-bigpicture (recado de até 30 s, em
-- BIGPICTURE_TARGET): o que a tela pedida mostrava. A Steam reaproveita a
-- própria janela, que pode estar em outro workspace, e ao virar Big Picture
-- pede foco, então o workspace de agora já é o dela. Sem recado (o botão da
-- Steam), nil: o Big Picture fica onde está
local function target_workspace()
	local hint = rawget(_G, "BIGPICTURE_TARGET")
	BIGPICTURE_TARGET = nil
	if type(hint) == "table" and hint.ws and hint.at and os.time() - hint.at <= 30 then
		return hint.ws
	end
	return nil
end

local function make_console(w)
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
	local id = w.workspace and w.workspace.id
	local wanted = target_workspace()
	if wanted and wanted ~= id then
		id = wanted
		hl.dispatch(hl.dsp.window.move({ window = sel, workspace = tostring(id), follow = true }))
	end
	if (w.fullscreen or 0) == 0 and not (id and other_fullscreen_on(id, w)) then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "fullscreen", action = "set", window = sel }))
	end
end

hl.on("window.open", make_console)
hl.on("window.title", make_console)
hl.on("window.close", function(w)
	if w then
		was_big_picture[w.address] = nil
	end
end)
