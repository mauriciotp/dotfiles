-- Jogos: a lista diz quem recebe a tag "game"; a definição diz o que a tag
-- faz (o padrão de tags do hyprland/rules.lua). Sem eventos, como no CachyOS
-- (inbox/Referências/CachyOS/hypr/config/windowrules.lua).
-- Os jogos vão para o 10 da tela em foco (SUPER+0), um workspace só deles.
-- Assim o jogo nunca cai em cima do Big Picture (só cabe uma janela em tela
-- cheia por workspace).
local F = require("utils.functions")

-- Quem recebe a tag. Jogo novo: acrescente a classe, exatamente como o
-- hyprctl clients mostra. As regras diferenciam maiúsculas.
F.tagged_rule("game", {
	"^steam_app_.*$", -- Steam
	"^gamescope$",
	"^.*\\.exe$", -- Proton do Heroic/Lutris
	"^io\\.github\\.NotRexed\\.Hookshot$", -- recomp: Zelda: Ocarina of Time
}, "class")

-- Emulador (Lichii): só a janela principal com um jogo rodando, pelo título,
-- que ganha o nome do jogo (visto em 2026-11-13):
--   sem jogo  "Lichii | build-160 | Clang 23.1.6"
--   com jogo  "Lichii | build-160 | Clang 23.1.6 | Donkey Kong Bananza (64-bit) | Nvidia"
-- Aberto já com o jogo (pelo ES-DE), vai para o 10; aberto pelo menu, fica
-- onde está, e o jogo escolhido depois só ganha os efeitos.
F.tagged_rule("game", {
	{ class = "^Lichii$", title = "^Lichii( \\| [^|]+){4,}$" },
})

F.create_tag("game", {
	workspace = "r~10", -- o 10 da tela em foco
	immediate = true, -- tearing permitido (chave geral em hyprland/general.lua)
	content = "game", -- liga o VRR e o direct scanout (hyprland/monitors.lua)
	-- a tela não apaga nem com o jogo em janela (o controle não conta como atividade)
	idle_inhibit = "always",
})

-- splash e launcher de jogo da Steam (título vazio ao abrir): flutuam no centro (CachyOS)
F.window("game-splash", { class = "^steam_app_.*$", initial_title = "^$" }, { float = true, center = true })

-- jogo em tela cheia: o mouse não escapa para a outra tela
F.window("game-confine-pointer", { tag = "game", fullscreen = true }, { confine_pointer = true })

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
