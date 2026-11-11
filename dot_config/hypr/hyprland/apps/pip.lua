-- Picture-in-picture (Firefox e outros navegadores): flutua, fixa em todos os
-- workspaces, canto superior direito. Pelo título, porque a classe é a do navegador.
local F = require("utils.functions")

F.window("pip", { title = "^(Picture.?in.?[Pp]icture)$" }, {
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	size = { "monitor_w*0.3", "monitor_h*0.3" },
	move = { "monitor_w-window_w-24", "monitor_h*0.06" },
})
