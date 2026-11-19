-- Obsidian: o pop-out ("abrir em nova janela") flutua em 60% × 70% da tela.
-- A principal e o pop-out nascem com o mesmo título, "Obsidian", e só depois
-- ganham "<nota> - <vault> - Obsidian <versão>" (eventos do Hyprland,
-- 2026-11-17). Regra não serve: flutuar só vale na abertura, e ali os dois são
-- iguais (wiki, Window Rules: static effects). Por evento, como no Bitwarden:
-- quando o título real chega, das janelas do mesmo vault a primeira aberta é a
-- principal (fica no tiling) e as outras flutuam. Outro vault continua no
-- tiling. Configurações, plugins e ajuda flutuam pela regra (hyprland/rules.lua).
local F = require("utils.functions")

local CLASS = require("variables").apps.obsidian.classes[1]

-- "<nota> - <vault> - Obsidian 1.15.1" ou "<vault> - Obsidian 1.15.1" → vault
local function vault_of(title)
	local rest = (title or ""):match("^(.-) %- Obsidian [%d%.]+$")
	if not rest then
		return nil
	end
	return rest:match(".* %- (.+)$") or rest
end

-- ordem de abertura por endereço (as abertas antes do reload ficam com 0, as
-- mais antigas); o endereço volta a ser usado depois de fechar (visto em 2026-11-17)
local opened_at, counter = {}, 0
-- seen: a janela já recebeu o primeiro título real (só esse conta)
-- floated: já flutuou por aqui; se você a puser no tiling, não volta a flutuar
local seen, floated = {}, {}

local function forget(address)
	opened_at[address], seen[address], floated[address] = nil, nil, nil
end

hl.on("window.open", function(w)
	if w and w.class == CLASS then
		forget(w.address)
		counter = counter + 1
		opened_at[w.address] = counter
	end
end)

hl.on("window.close", function(w)
	if w then
		forget(w.address)
	end
end)

local function float_popout(w)
	local sel = "address:" .. w.address
	hl.dispatch(hl.dsp.window.float({ window = sel, action = "enable" }))
	local size = F.resize_by_screen(60, 70)
	if size then
		size.window = sel
		hl.dispatch(hl.dsp.window.resize(size))
	end
	hl.dispatch(hl.dsp.window.center({ window = sel }))
end

hl.on("window.title", function(w)
	if not w or w.class ~= CLASS or w.initial_title ~= "Obsidian" or seen[w.address] then
		return
	end
	local vault = vault_of(w.title)
	if not vault then
		return -- ainda "Obsidian" (ou o seletor de vaults)
	end
	seen[w.address] = true

	-- as janelas do mesmo vault, e qual delas abriu primeiro. A ordem dos
	-- títulos não é garantida (o Obsidian reabre os pop-outs junto com a
	-- principal), por isso a decisão é pela ordem de abertura, e o pop-out que
	-- recebeu o título antes da principal flutua quando o título dela chega.
	local same, main = {}, nil
	for _, other in ipairs(hl.get_windows() or {}) do
		if other.class == CLASS and other.initial_title == "Obsidian" and vault_of(other.title) == vault then
			same[#same + 1] = other
			if not main or (opened_at[other.address] or 0) < (opened_at[main.address] or 0) then
				main = other
			end
		end
	end
	for _, other in ipairs(same) do
		if other.address ~= main.address and not other.floating and not floated[other.address] then
			floated[other.address] = true
			float_popout(other)
		end
	end
end)
