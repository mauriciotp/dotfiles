-- Noctalia (doc oficial: docs.noctalia.dev → Compositor Settings → Hyprland)
local L = require("lib")

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
L.float("noctalia-settings", { class = "^dev\\.noctalia\\.Noctalia$" }, { 1080, 920 })
