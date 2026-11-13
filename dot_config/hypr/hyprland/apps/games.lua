-- Jogos, no formato do CachyOS (inbox/Referências/CachyOS/hypr/config/windowrules.lua):
-- uma lista de classes e regras diretas, sem tags nem eventos.
-- Os jogos abrem no workspace "gaming", criado na tela em foco; ele some
-- quando o último jogo fecha. Assim o jogo nunca cai em cima do Big Picture
-- (só cabe uma janela em tela cheia por workspace).
local F = require("utils.functions")

-- Steam (steam_app_*), gamescope, Proton do Heroic/Lutris (*.exe) e recomps.
-- Jogo novo: acrescente a classe, exatamente como o hyprctl clients mostra.
local games = "^(steam_app_.*|gamescope|.*\\.exe|io\\.github\\.NotRexed\\.Hookshot)$"
local gaming = "name:gaming"

-- O que um jogo ganha:
--   immediate     tearing permitido (chave geral em hyprland/general.lua)
--   content       "game": liga o VRR e o direct scanout (hyprland/monitors.lua)
--   idle_inhibit  a tela não apaga nem com o jogo em janela (o controle não
--                 conta como atividade)
F.window("game", { class = games }, { workspace = gaming, immediate = true, content = "game", idle_inhibit = "always" })

-- Emulador (Lichii): só a janela principal com um jogo rodando, pelo título,
-- que ganha o nome do jogo (visto em 2026-11-13):
--   sem jogo  "Lichii | build-160 | Clang 23.1.6"
--   com jogo  "Lichii | build-160 | Clang 23.1.6 | Donkey Kong Bananza (64-bit) | Nvidia"
-- Aberto já com o jogo (pelo ES-DE), vai para o gaming; aberto pelo menu, fica
-- onde está, e o jogo escolhido depois só ganha os efeitos.
F.window("game-emulator", { class = "^Lichii$", title = "^Lichii( \\| [^|]+){4,}$" }, {
	workspace = gaming,
	immediate = true,
	content = "game",
	idle_inhibit = "always",
})

-- splash e launcher de jogo da Steam (título vazio ao abrir): flutuam no centro (CachyOS)
F.window("game-splash", { class = "^steam_app_.*$", initial_title = "^$" }, { float = true, center = true })

-- jogo em tela cheia: o mouse não escapa para a outra tela
F.window("game-confine-pointer", { content = "game", fullscreen = true }, { confine_pointer = true })

-- Direct scanout só para conteúdo marcado como jogo; volte para 0 se houver artefatos
hl.config({ render = { direct_scanout = 2 } })
