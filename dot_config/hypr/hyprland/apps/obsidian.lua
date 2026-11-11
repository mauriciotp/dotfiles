-- Obsidian: Settings, Community plugins e Community themes abrem como janelas
-- normais (Electron, sem janela-pai): sem isto cada uma vira um tiling novo.
-- A regra que faz as janelas extras flutuarem está em hyprland/rules.lua.
local F = require("utils.functions")

F.single_main_window["md.obsidian.Obsidian"] = true
