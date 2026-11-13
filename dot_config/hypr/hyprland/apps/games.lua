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
	-- Recomps (jogos recompilados para PC): a classe é o app id da janela
	"^io\\.github\\.NotRexed\\.Hookshot$", -- Zelda: Ocarina of Time (Hookshot)
	"^es-de$", -- ES-DE: o frontend conta como jogo, junto com os jogos que ele abre
}, "class")

-- Emuladores: só a janela principal, e só com um jogo rodando. O título dela
-- ganha o nome do jogo (visto em 2026-11-13):
--   sem jogo  "Lichii | build-160 | Clang 23.1.6"
--   com jogo  "Lichii | build-160 | Clang 23.1.6 | Donkey Kong Bananza (64-bit) | Nvidia"
-- A tag é dinâmica: entra quando o jogo começa e sai quando ele para. As outras
-- janelas do emulador (configurações, a janela "Lichii" que abre junto do jogo)
-- ficam sem a tag e abrem no workspace atual, como qualquer app. No X11 o Lichii
-- se chama "Lichii"; no Wayland, pelo app id do .desktop
F.tagged_rule("game", {
	{ class = "^Lichii$", title = "^Lichii( \\| [^|]+){4,}$" },
	{ class = "^io\\.github\\.zortos293\\.lichii$", title = "^Lichii( \\| [^|]+){4,}$" },
})

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

F.window("game-confine-pointer", { tag = "game", fullscreen = true }, {
	confine_pointer = true, -- o mouse não escapa para o outro monitor
})

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
