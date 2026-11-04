-- Firefox: workspace 2 (web)
local W = require("workspaces")

W.app("ws-web", { class = "^firefox$" }, 2)

-- Picture-in-picture: flutua, fixa em todos os workspaces, canto superior direito
hl.window_rule({
	name = "pip",
	match = { title = "^(Picture.?in.?[Pp]icture)$" },
	float = true,
	pin = true,
	keep_aspect_ratio = true,
	size = { "monitor_w*0.3", "monitor_h*0.3" },
	move = { "monitor_w-window_w-24", "monitor_h*0.06" },
})
