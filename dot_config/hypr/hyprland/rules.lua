-- Regras de janela que valem para mais de um app: regras gerais, tags e
-- workspaces. Um app entra numa categoria (flutuar, tiling, especial) pelas
-- listas de tag daqui; o que só ele tem (tamanho exato, evento) fica em
-- hyprland/apps/<app>.lua.
local F = require("utils.functions")
local vars = require("variables")
local window, tagged_rule, create_tag = F.window, F.tagged_rule, F.create_tag

-- ===== Regras gerais =====

-- Ignora pedidos de "maximizar" dos apps (atrapalham o tiling)
window("suppress-maximize", ".*", { suppress_event = "maximize" })

-- Vídeo ou jogo em tela cheia impede o bloqueio e o desligamento das telas
window("idle-fullscreen", ".*", { idle_inhibit = "fullscreen" })

-- Popups vazios do XWayland (menus da Steam etc.) não roubam o foco (Omarchy)
window(
	"xwayland-empty-popups",
	{ class = "^$", title = "^$", xwayland = true, float = true, fullscreen = false, pin = false },
	{ no_focus = true }
)

-- ===== Janelas do sistema =====
-- O Hyprland já flutua sozinho janelas com janela-pai ou de tamanho fixo
-- (e diálogos X11). Aqui ficam só as que deveriam flutuar mas não avisam.
-- Para saber se uma regra sobra: comente, recarregue (SUPER+CTRL+R), abra a janela.

-- senha do GPG/SSH (pinentry-gtk): flutua, não perde o foco e sai preta em
-- gravações e compartilhamentos de tela (no_screen_share, Omarchy). Q1
window("pinentry", "^pinentry-.*$", { float = true, center = true, size = { 520, 220 }, stay_focused = true, no_screen_share = true })
-- escolher a tela ao compartilhar (xdg-desktop-portal-hyprland)
window("share-picker", "^hyprland-share-picker$", { float = true, center = true, size = { 640, 480 } })

-- Aviso "está compartilhando a tela" do navegador: vai para um especial que
-- nunca é aberto (Omarchy); o Firefox já mostra o controle na barra dele. Q5
window("sharing-indicator", { title = ".*is sharing.*" }, { workspace = "special:sharing silent" })

-- Toda janela flutuante nasce centralizada, menos as do XWayland: no XWayland,
-- menus e popups também são janelas (Caelestia). R7
window("center-floating", { float = true, xwayland = false }, { center = true })

-- Janela fixada em todos os workspaces (pin) com a borda em outra cor
-- (dots-hyprland), para saber qual está fixada. A cor vem do Noctalia. R15
local ok, noctalia = pcall(require, "noctalia")
if ok and noctalia.colors then
	window("pinned-border", { pin = true }, { border_color = noctalia.colors.secondary })
end

-- Margem maior no workspace especial: deixa claro que é uma camada por cima
-- (dots-hyprland). R16
hl.workspace_rule({ workspace = "s[true]", gaps_out = 30 })

-- Layers sem animação: o seletor de cor e a seleção de região (Caelestia,
-- dots-hyprland). R17
hl.layer_rule({ name = "no-anim-pickers", match = { namespace = "^(hyprpicker|selection)$" }, no_anim = true })

-- ===== Listas por tag =====
-- Para um app ganhar o comportamento de uma tag, acrescente a classe dele na
-- lista (como o hyprctl clients mostra, em regex).

-- Tags de tamanho (Caelestia): flutua, centraliza e ocupa uma % da tela.
-- float_50_60, float_60_70 e float_70_80; "float" só flutua; "float_small"
-- tem tamanho fixo, para visualizadores (Omarchy, floating-window). R3, Q3

-- 60% × 70%
tagged_rule("float_60_70", {
	"^xdg-desktop-portal-gtk$", -- seletor de arquivos do portal, para apps que não informam a janela-pai
	-- programa de terminal flutuante (Omarchy, TUI.float): qualquer
	-- "ghostty --class=com.mauricio.float -e <programa>" abre assim; a cola do
	-- SUPER+F1 usa esta classe. Q4
	"^com\\.mauricio\\.float$",
}, "class")
-- diálogos de arquivo pelo título, para os apps que não usam o portal
-- (Caelestia, dots-hyprland). Os títulos estão em inglês: um app em português
-- não casa. R4
tagged_rule("float_60_70", {
	"(Select|Open)( a)? (File|Folder)(s)?",
	"Save As",
}, "title")

-- só flutua
tagged_rule("float", { "^zenity$" }, "class") -- diálogos de scripts. R6
tagged_rule("float", {
	"File (Operation|Upload)( Progress)?", -- progresso de cópia e envio
	".* Properties", -- propriedades de um arquivo
	'Rename ".*"', -- renomear
}, "title") -- R5
-- diálogos modais ("tem certeza?", "salvar alterações?") de qualquer app, em
-- qualquer idioma: a janela se declara modal, sem depender do título (HyDE)
tagged_rule("float", { { modal = true } })

-- Apps que abrem janelas extras sem janela-pai (configurações, propriedades,
-- chat): todas as janelas flutuam, e a tag "tile" (abaixo) devolve a principal
-- ao tiling pelo título inicial. Por regra, e não por evento: nada se move
-- depois de abrir (Caelestia, dots-hyprland; comparativo "janelas que deveriam
-- flutuar" no vault de inspirações, 2026-11-17).
-- App novo assim: a classe aqui e a janela principal na lista "tile".
tagged_rule("float", { "^steam$" }, "class") -- no tamanho que a Steam pede
tagged_rule("float_60_70", { "^md\\.obsidian\\.Obsidian$" }, "class")

-- tamanho fixo (875 × 600): mpv, imv e outros visualizadores, quando instalados
-- tagged_rule("float_small", { "^(mpv|imv)$" }, "class")

-- popups do XWayland (menus da Steam e de jogos): sem blur, sem sombra, sem
-- escurecer, opacos e com cantos pequenos (Caelestia). R9
tagged_rule("xwl_popup", {
	{ xwayland = true, title = "win[0-9]+" },
	{ xwayland = true, title = "^$", class = "^$", initial_title = "^$", initial_class = "^$" },
	{ class = "^steam$", title = "^$" },
})

-- Tiling, mesmo que outra tag ou o próprio app peça para flutuar (a definição
-- vem depois das de flutuar, e a última regra vence):
-- navegadores Chromium (Chrome, Brave, Edge, Vivaldi), cujos web apps nascem
-- flutuando (Omarchy). Q10
tagged_rule("tile", {
	"^((google-)?[cC]hrom(e|ium)|[bB]rave-browser|[mM]icrosoft-edge|Vivaldi-stable|helium)$",
}, "class")
-- a janela principal dos apps de janelas extras (acima). A Steam às vezes
-- nasce flutuando sozinha (thinglab.org, 2026-01)
tagged_rule("tile", {
	{ class = "^steam$", initial_title = "^Steam$" },
	-- Obsidian: "Obsidian" (aberto pelo seletor de vaults) ou "<vault> - Obsidian
	-- <versão>" (aberto direto no vault: "SecondBrain - Obsidian 1.15.1"). Um "-"
	-- só antes de "Obsidian": as janelas extras abrem como "Settings - <vault> -
	-- Obsidian 1.15.1" e "Community plugins - <vault> - ..." e têm de flutuar
	-- (eventos do Hyprland, 2026-11-17). Vault com "-" no nome abre flutuando.
	-- O pop-out ("abrir em nova janela") nasce "Obsidian", como a principal:
	-- esse é tratado por evento em hyprland/apps/obsidian.lua.
	{ class = "^md\\.obsidian\\.Obsidian$", initial_title = "^(Obsidian|[^-]+ - Obsidian [0-9.]+)$" },
})

-- workspaces especiais: as classes vêm da tabela toggles do variables.lua.
-- Tag <especial>_app, uma por especial (music_app, sysmon_app).
for special, apps in pairs(vars.toggles) do
	for _, app in pairs(apps) do
		tagged_rule(special .. "_app", { F.exact_regex(app.classes) }, "class")
	end
end

-- ===== Definição das tags =====
-- Sempre depois das listas: a regra da tag só enxerga as tags já dadas acima.
create_tag("float", { float = true })
create_tag("float_50_60", { float = true, center = true, size = { "monitor_w*0.5", "monitor_h*0.6" } })
create_tag("float_60_70", { float = true, center = true, size = { "monitor_w*0.6", "monitor_h*0.7" } })
create_tag("float_70_80", { float = true, center = true, size = { "monitor_w*0.7", "monitor_h*0.8" } })
create_tag("float_small", { float = true, center = true, size = { 875, 600 } })
create_tag("xwl_popup", {
	no_dim = true,
	no_shadow = true,
	no_blur = true,
	opaque = true,
	rounding = math.min(10, vars.windowRounding), -- popups são pequenos
})
create_tag("tile", { tile = true }) -- depois das de flutuar: vence elas
-- janela do pop-out (SUPER+P) com cantos menores (Omarchy). Q8
create_tag("pop", { rounding = 8 })
-- silent: o app aberto pelo launcher ou no login vai para o especial sem mostrá-lo
for special in pairs(vars.toggles) do
	create_tag(special .. "_app", { workspace = "special:" .. special .. " silent" })
end

-- ===== Pop-out (SUPER+P, hyprland/keybinds.lua) =====
-- O Hyprland leva a janela flutuante a outro monitor na mesma distância da
-- origem, e ela cairia fora do centro ou fora da tela menor. A janela com a tag
-- "pop" é recentralizada depois de chegar (Omarchy, pop.lua): o evento vem antes
-- da mudança, por isso o timer.
hl.on("window.move_to_workspace", function(w, ws)
	if not (w and ws and w.monitor and ws.monitor) or w.monitor.id == ws.monitor.id or not F.has_tag(w, "pop") then
		return
	end
	local sel = "address:" .. w.address
	hl.timer(function()
		hl.dispatch(hl.dsp.window.center({ window = sel }))
	end, { timeout = 1, type = "oneshot" })
end)
