-- Funções comuns aos arquivos de atalhos (binds/) e de regras (apps/).
local L = {}

L.mod = "SUPER"
L.ipc = "noctalia msg " -- IPC do Noctalia (docs.noctalia.dev → IPC)
-- Caminho absoluto: o PATH do Hyprland não inclui ~/.local/bin
L.bin = os.getenv("HOME") .. "/.local/bin/"

-- bind(teclas, descrição, ação, flags opcionais).
-- Toda bind tem descrição: o SUPER+F1 lista todas (script ~/.local/bin/keybinds).
function L.bind(keys, desc, action, flags)
	flags = flags or {}
	flags.description = desc
	hl.bind(keys, action, flags)
end

-- Abre ou foca um app (~/.local/bin/launch-or-focus)
function L.app(class, cmd)
	return hl.dsp.exec_cmd(string.format("%slaunch-or-focus '%s' %s", L.bin, class, cmd))
end

-- Abre sempre uma janela nova (dentro do uwsm vira unidade do systemd)
function L.run(cmd)
	return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

-- Apps cujas janelas extras flutuam (preenchida em apps/, usada em apps/system.lua)
L.single_main_window = {}

return L
