-- Workspaces especiais (scratchpad e música) e a cola de atalhos (SUPER+F1)
local L = require("lib")

-- O scratchpad (SUPER+crase, binds/workspaces.lua) começa vazio: você manda
-- janelas para ele com SUPER+SHIFT+crase.
-- escurece o que está embaixo enquanto um workspace especial está aberto (Omarchy)
hl.config({ decoration = { dim_special = 0.6 } })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "smooth", style = "slidevert" })

-- cola de atalhos: janela comum do Ghostty
L.float("keybinds", { class = "^com\\.mauricio\\.keybinds$" }, L.medium)
