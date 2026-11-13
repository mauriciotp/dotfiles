-- Jogos: Steam (steam_app_*), gamescope, jogos do Heroic/Lutris pelo Proton
-- (*.exe) e emuladores. Abrem no workspace atual, como qualquer app: a tag só
-- muda como eles rodam (tearing, VRR, tela sem apagar). A exceção é o
-- workspace da Steam (abaixo).
local F = require("utils.functions")
local W = require("utils.workspaces")

-- Quem recebe a tag "game". As regras diferenciam maiúsculas.
-- Emulador ou recomp novo: acrescente a classe aqui, exatamente como o hyprctl clients mostra.
F.tagged_rule("game", {
	"^steam_app_.*$",
	"^gamescope$",
	"^.*\\.exe$",
	-- Emuladores: a janela inteira conta como jogo (a lista de jogos também).
	-- No X11 o Lichii se chama "Lichii" (visto no hyprctl clients);
	-- no Wayland, pelo app id do .desktop.
	"^[Ll]ichii$",
	"^io\\.github\\.zortos293\\.lichii$",
	-- Recomps (jogos recompilados para PC): a classe é o app id da janela
	"^io\\.github\\.NotRexed\\.Hookshot$", -- Zelda: Ocarina of Time (Hookshot)
	"^es-de$", -- ES-DE: o frontend conta como jogo, junto com os jogos que ele abre
}, "class")

F.create_tag("game", {
	immediate = true, -- tearing permitido (só em tela cheia; chave geral no hyprland/general.lua)
	content = "game", -- liga o direct scanout automático e o VRR (hyprland/monitors.lua)
	-- a tela não apaga nem bloqueia com um jogo aberto, mesmo em janela (o
	-- controle não conta como atividade); vale sobre a regra geral de tela
	-- cheia (hyprland/rules.lua), que vem antes. Caelestia, H4
	idle_inhibit = "always",
})

-- Jogo e Steam no mesmo workspace brigam pela tela cheia (só cabe uma por
-- workspace): o jogo tira o Big Picture da tela cheia, e focar a Steam tira o
-- jogo. Por isso, se a Steam (normal ou Big Picture) está no workspace onde o
-- jogo abriu, ele vai para o primeiro workspace vazio da mesma tela, com o foco
-- junto. A comunidade separa os dois do mesmo jeito, com um workspace fixo
-- para jogos (CachyOS) ou para a Steam (fórum do Hyprland)
hl.on("window.open", function(w)
	if not (w and w.workspace and w.monitor and F.has_tag(w, "game")) then
		return
	end
	local here = w.workspace.id
	local steam_here = false
	for _, other in ipairs(hl.get_windows()) do
		if other.class == "steam" and other.workspace and other.workspace.id == here then
			steam_here = true
		end
	end
	if not steam_here then
		return
	end
	local free = W.first_free(w.monitor, here)
	if free then
		hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = tostring(free), follow = true }))
	end
end)

F.window("game-confine-pointer", { tag = "game", fullscreen = true }, {
	confine_pointer = true, -- o mouse não escapa para o outro monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
