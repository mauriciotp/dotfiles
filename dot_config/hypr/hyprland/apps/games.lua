-- Jogos: Steam (steam_app_*), gamescope, jogos do Heroic/Lutris pelo Proton
-- (*.exe) e emuladores. Abrem no primeiro workspace vazio da tela em foco, e
-- a tag muda como eles rodam (tearing, VRR, tela sem apagar).
local F = require("utils.functions")

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
	-- primeiro workspace vazio da tela em foco (seletor emptym). Por regra, e não
	-- por evento: vale antes de a janela aparecer, então o jogo nunca nasce em
	-- cima da Steam. Só cabe uma janela em tela cheia por workspace, e um jogo no
	-- workspace do Big Picture tirava a tela cheia dele (testado em 2026-11-13)
	workspace = "emptym",
	immediate = true, -- tearing permitido (só em tela cheia; chave geral no hyprland/general.lua)
	content = "game", -- liga o direct scanout automático e o VRR (hyprland/monitors.lua)
	-- a tela não apaga nem bloqueia com um jogo aberto, mesmo em janela (o
	-- controle não conta como atividade); vale sobre a regra geral de tela
	-- cheia (hyprland/rules.lua), que vem antes. Caelestia, H4
	idle_inhibit = "always",
})

-- Só a primeira janela de cada jogo fica no workspace vazio. As outras
-- (configurações de um emulador, o jogo que o launcher abre) voltam para o
-- workspace do jogo, com o foco junto. Uma janela é "do mesmo jogo" se já existe
-- uma janela com a tag game do mesmo processo ou da mesma classe. Duas sessões
-- do gamescope não contam como o mesmo jogo, e o ES-DE abrindo um emulador
-- também não (outro processo, outra classe).
-- Por evento, depois de a janela abrir: uma tag dada no window.open_early não
-- chega a tempo de mudar o workspace da regra (testado em 2026-11-13)
hl.on("window.open", function(w)
	if not (w and w.workspace and F.has_tag(w, "game")) then
		return
	end
	for _, other in ipairs(hl.get_windows()) do
		if
			other.address ~= w.address
			and other.mapped
			and other.workspace
			and F.has_tag(other, "game")
			and (other.pid == w.pid or (other.class == w.class and w.class ~= "gamescope"))
		then
			if other.workspace.id ~= w.workspace.id then
				hl.dispatch(hl.dsp.window.move({
					window = "address:" .. w.address,
					workspace = tostring(other.workspace.id),
					follow = true,
				}))
			end
			return
		end
	end
end)

F.window("game-confine-pointer", { tag = "game", fullscreen = true }, {
	confine_pointer = true, -- o mouse não escapa para o outro monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
