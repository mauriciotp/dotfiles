-- Ponto de entrada: só carrega os outros arquivos.
-- Variáveis de ambiente NÃO ficam aqui: estão em ~/.config/uwsm/env (wiki do Hyprland).
-- Estrutura (inspirada no Omarchy):
--   monitors, look, input   telas, aparência, teclado e mouse
--   workspaces              workspaces por monitor e o workspace dos jogos
--   binds/                  atalhos por contexto
--   apps/                   regras por app (workspace, janelas flutuantes)
require("monitors")
require("look")
require("input")
require("workspaces")

for _, f in ipairs({ "apps", "shell", "capture", "windows", "workspaces", "media" }) do
	require("binds." .. f)
end

for _, f in ipairs({ "system", "noctalia", "terminals", "firefox", "discord", "obsidian", "obs", "k9s", "steam", "spotify", "games" }) do
	require("apps." .. f)
end

require("autostart")

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
