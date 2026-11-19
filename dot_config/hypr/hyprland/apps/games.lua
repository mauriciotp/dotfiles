-- Jogos: a lista diz quem recebe a tag "game"; a definição diz o que a tag
-- faz (o padrão de tags do hyprland/rules.lua). Sem eventos, como no CachyOS
-- (github.com/CachyOS/cachyos-hyprland-settings, config/windowrules.conf).
-- Os jogos vão para o 10 da tela em foco (SUPER+0), um workspace só deles.
-- Assim o jogo nunca cai em cima do Big Picture (só cabe uma janela em tela
-- cheia por workspace). O gamescope ganha os efeitos de jogo, mas fica onde
-- abriu: o Big Picture no gamescope (steam-bigpicture) nasce no workspace que a
-- tela pedida mostra (decisão de 2026-11-18).
local F = require("utils.functions")

-- Quem recebe a tag. Jogo novo: acrescente a classe, exatamente como o
-- hyprctl clients mostra. As regras diferenciam maiúsculas.
F.tagged_rule("game", {
	"^steam_app_.*$", -- Steam
	"^gamescope$",
	"^.*\\.exe$", -- Proton do Heroic/Lutris
	"^dev\\.magicbean\\.Longshot$", -- recomp: Zelda: Ocarina of Time (Longshot)
	"^mkw-recomp$", -- recomp: Mario Kart World (mkw-recomp)
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

-- Jogos do Proton pelo Wayland (o caminho do HDR, PROTON_ENABLE_WAYLAND=1): o
-- winewayland do GE-Proton marca a janela com a xdg_tag "proton-game" (visto no
-- winewayland.so, 2026-11-13), e a classe pode não ser nenhuma das de cima.
-- Pelo XWayland, que é o padrão, não há marca: valem as classes (Reddit, 2026-07)
F.tagged_rule("game", { { xdg_tag = "proton-game" } })

-- Nem todo .exe é jogo: instaladores, desinstaladores, atualizadores e os
-- launchers das lojas (Battle.net, EA, Ubisoft, GOG, Rockstar) também rodam pelo
-- Wine, e não devem ir para o 10 nem impedir a tela de apagar. Esta regra tira a
-- tag que a lista acima deu; vem depois dela e antes da definição. (?i): o Wine
-- mantém a caixa do nome do arquivo (Setup.exe, setup.exe). Launcher novo que
-- vire "jogo": acrescente o nome aqui.
hl.window_rule({
	name = "game-not-wine-tools",
	match = {
		class = [[(?i)^(.*(setup|install|unins|redist|update|launcher|crashreport).*|battle\.net|eadesktop|origin|upc|galaxyclient|socialclubhelper)\.exe$]],
	},
	tag = "-game",
})

F.create_tag("game", {
	immediate = true, -- tearing permitido (chave geral em hyprland/general.lua)
	content = "game", -- liga o VRR e o direct scanout (hyprland/monitors.lua)
	-- a tela não apaga nem com o jogo em janela (o controle não conta como atividade)
	idle_inhibit = "always",
	-- sempre opaco, com ou sem foco: o inactive_opacity (variables.lua) deixaria
	-- o jogo translúcido sem foco, e o Hyprland teria de desenhar o que está
	-- atrás, com blur, e perderia o direct scanout
	opaque = true,
	-- continua desenhando quando você troca de workspace (o padrão é parar):
	-- a partida online e a captura do OBS não congelam. O ritmo sem foco é o
	-- misc.render_unfocused_fps (padrão 15 fps) (Mainstream, fork do end-4)
	render_unfocused = true,
})

-- o 10 da tela em foco, menos o gamescope (veja o topo)
F.window("game-workspace", { tag = "game", class = "negative:^gamescope$" }, { workspace = "r~10" })

-- splash e launcher de jogo da Steam (título vazio ao abrir): flutuam no centro (CachyOS)
F.window("game-splash", { class = "^steam_app_.*$", initial_title = "^$" }, { float = true, center = true })

-- jogo em tela cheia: o mouse não escapa para a outra tela
F.window("game-confine-pointer", { tag = "game", fullscreen = true }, { confine_pointer = true })
