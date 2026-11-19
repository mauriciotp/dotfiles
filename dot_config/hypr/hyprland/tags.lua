-- O que cada tag faz. Quem recebe a tag fica nas listas: as categorias em
-- hyprland/rules.lua e o que é de um app só em hyprland/apps/<app>.lua.
-- Carregado depois dos dois (hyprland.lua): a regra de uma tag só enxerga as
-- tags dadas por regras anteriores, então a definição vem depois de todas as
-- listas. A tag "game" é a exceção: lista e definição ficam juntas em
-- hyprland/apps/games.lua, porque só os jogos a usam.
local F = require("utils.functions")
local vars = require("variables")
local create_tag = F.create_tag

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
