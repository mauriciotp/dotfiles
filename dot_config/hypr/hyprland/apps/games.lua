-- Jogos: Steam (steam_app_*), gamescope, jogos do Heroic/Lutris pelo Proton
-- (*.exe) e emuladores. Vão para o workspace 10, que fica na TV quando ela está
-- ligada pelo SUPER+ALT+O e no monitor quando não (utils/workspaces.lua).
local F = require("utils.functions")
local W = require("utils.workspaces")

-- Quem recebe a tag "game". As regras diferenciam maiúsculas.
-- Emulador ou recomp novo: acrescente a classe aqui, exatamente como o hyprctl clients mostra.
F.tagged_rule("game", {
	"^steam_app_.*$",
	"^gamescope$",
	"^.*\\.exe$",
	-- Emuladores: a janela inteira conta como jogo (a lista de jogos também vai
	-- para o 10). No X11 o Lichii se chama "Lichii" (visto no hyprctl clients);
	-- no Wayland, pelo app id do .desktop.
	"^[Ll]ichii$",
	"^io\\.github\\.zortos293\\.lichii$",
	-- Recomps (jogos recompilados para PC): a classe é o app id da janela
	"^io\\.github\\.NotRexed\\.Hookshot$", -- Zelda: Ocarina of Time (Hookshot)
	"^es-de$", -- ES-DE: o frontend abre no 10, junto com os jogos que ele abre
}, "class")

F.create_tag("game", {
	workspace = tostring(W.GAMES),
	immediate = true, -- tearing permitido (só em tela cheia; chave geral no hyprland/general.lua)
	content = "game", -- liga o direct scanout automático e o VRR (hyprland/monitors.lua)
	-- a tela não apaga nem bloqueia com um jogo aberto, mesmo em janela (o
	-- controle não conta como atividade); vale sobre a regra geral de tela
	-- cheia (hyprland/rules.lua), que vem antes. Caelestia, H4
	idle_inhibit = "always",
})

F.window("game-confine-pointer", { tag = "game", fullscreen = true }, {
	confine_pointer = true, -- o mouse não escapa para o outro monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
