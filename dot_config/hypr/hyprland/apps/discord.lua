-- Discord: não pode pedir foco. Sem isto, uma mensagem abriria o especial
-- "communication" no meio de um jogo (focus_on_activate está ligado para os
-- outros apps, hyprland/misc.lua). Omarchy faz o mesmo com o Telegram. Q7
local F = require("utils.functions")

F.window("discord-no-focus-steal", "^(discord|vesktop)$", { focus_on_activate = false })
