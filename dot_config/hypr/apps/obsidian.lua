-- Obsidian: workspace 4 (notes)
local L = require("lib")
local W = require("workspaces")

W.app("ws-notes", { class = "^md\\.obsidian\\.Obsidian$" }, 4)

-- Settings, Community plugins e Community themes abrem como janelas normais
-- (Electron, sem janela-pai): sem isto cada uma vira um tiling novo
L.single_main_window["md.obsidian.Obsidian"] = true
