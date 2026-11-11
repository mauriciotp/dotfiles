-- Noctalia (doc oficial: docs.noctalia.dev → Compositor Settings → Hyprland)
local F = require("utils.functions")

-- blur nos painéis, sem a animação de camada do Hyprland
hl.layer_rule({
	name = "noctalia",
	match = { namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$" },
	no_anim = true,
	ignore_alpha = 0.5,
	blur = true,
	blur_popups = true,
})

-- janela de configurações (SUPER+vírgula)
F.window("noctalia-settings", "^dev\\.noctalia\\.Noctalia$", { float = true, center = true, size = { 1080, 920 } })
