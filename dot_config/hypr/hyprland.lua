-- Ponto de entrada: só carrega os outros arquivos da mesma pasta.
-- Variáveis de ambiente NÃO ficam aqui: estão em ~/.config/uwsm/env (wiki do Hyprland).
require("monitors")
require("look")
require("input")
require("binds")
require("rules")
require("autostart")
require("games")

-- For Noctalia Color templates
require("noctalia").apply_theme()
