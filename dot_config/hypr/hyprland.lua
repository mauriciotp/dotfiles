-- Ponto de entrada: só carrega os outros arquivos da mesma pasta
require("env")
require("monitors")
require("look")
require("input")
require("binds")
require("rules")
require("autostart")
require("games") -- descomente na seção 11

-- For Noctalia Color templates
require("noctalia").apply_theme()
