-- Discord: workspace 3 (chat); no segundo monitor, quando houver
local W = require("workspaces")

W.app("ws-chat", { class = "^(discord|vesktop)$" }, 3)
