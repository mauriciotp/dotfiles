-- OBS: workspace 5 (media); no segundo monitor, quando houver
local W = require("workspaces")

W.app("ws-media", { class = "^com\\.obsproject\\.Studio$" }, 5)
