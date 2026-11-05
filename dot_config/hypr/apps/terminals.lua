-- Terminais: o console (SUPER+crase) e a cola de atalhos (SUPER+F1)
local L = require("lib")

-- Console: workspace especial com um Ghostty na sessão tmux "console".
-- Abre na primeira vez que o workspace é criado; depois só aparece e some.
-- (on_created_empty está obsoleto no 0.57: hyprctl deprecated-config)
-- O workspace vem da regra da classe, não do exec: com o uwsm o app nasce numa
-- unidade do systemd, e a regra do exec (casada pelo PID) pode não pegar.
hl.on("workspace.created", function(ws)
	if ws and ws.name == "special:console" and ws.is_empty then
		hl.exec_cmd("uwsm app -- ghostty --class=com.mauricio.console -e tmux new-session -A -s console")
	end
end)
-- metade de cima da tela, centralizado
hl.window_rule({
	name = "console",
	match = { class = "^com\\.mauricio\\.console$" },
	workspace = "special:console silent",
	float = true,
	size = { "monitor_w*0.7", "monitor_h*0.5" },
	move = { "monitor_w*0.15", "monitor_h*0.05" },
})
-- escurece o que está embaixo enquanto um workspace especial está aberto (Omarchy)
hl.config({ decoration = { dim_special = 0.6 } })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "smooth", style = "slidevert" })

-- cola de atalhos: janela comum do Ghostty
L.float("keybinds", { class = "^com\\.mauricio\\.keybinds$" }, L.medium)
