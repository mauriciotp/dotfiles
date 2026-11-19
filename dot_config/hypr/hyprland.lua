-- Ponto de entrada: só carrega os outros arquivos, nesta ordem.
-- Variáveis de ambiente NÃO ficam aqui: estão em ~/.config/uwsm/env (wiki do Hyprland).
-- Estrutura (Caelestia, com a pasta apps/ do Omarchy):
--   variables.lua        apps, telas e valores (sem teclas)
--   hyprland/            um arquivo por seção do Hyprland
--   hyprland/rules.lua   regras gerais e as listas de tag por categoria
--   hyprland/apps/       o que só um app tem (listas de tag dele, tamanho, evento)
--   hyprland/tags.lua    o que cada tag faz; depois dos dois, porque a regra
--                        de uma tag só enxerga as tags dadas antes dela
--   utils/               funções (bind, run, window, tags) e os workspaces por monitor
require("hyprland.monitors")
require("hyprland.general")
require("hyprland.input")
require("hyprland.misc")
require("hyprland.animations")
require("hyprland.decoration")
require("utils.workspaces")
require("hyprland.execs")
require("hyprland.rules")

-- App novo com regra própria: crie o arquivo em hyprland/apps/ e ponha o nome aqui
for _, app in ipairs({ "games", "steam", "bitwarden", "discord", "obsidian", "pip", "noctalia" }) do
	require("hyprland.apps." .. app)
end
require("hyprland.tags")

require("hyprland.keybinds")

-- Cores do Noctalia: o arquivo é gerado pelo template "hyprland".
-- Sem ele (instalação nova), o Hyprland sobe sem o tema em vez de dar erro.
-- O texto require("noctalia") precisa aparecer escrito assim: o hook do template
-- procura por ele e, se não achar, acrescenta outra chamada no fim do arquivo.
local ok, noctalia = pcall(function()
	return require("noctalia")
end)
if ok then
	noctalia.apply_theme()
end
