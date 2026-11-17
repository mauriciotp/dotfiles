-- Janelas translúcidas, para ver o blur atrás delas (Omarchy, window-glassy).
-- Pela opacidade geral, e não por regra: os jogos (opaque, apps/games.lua) e
-- quem estiver opaco pelo SUPER+BackSpace continuam opacos.
hl.config({ decoration = { active_opacity = 0.85, inactive_opacity = 0.8, blur = { popups = true } } })
