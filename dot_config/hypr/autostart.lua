-- Noctalia pelo uwsm: roda como unidade do systemd do usuário. Isso permite o
-- launch_apps_as_systemd_services do Noctalia (apps do launcher sobrevivem a um
-- reinício do shell e ganham cgroup próprio).
hl.on("hyprland.start", function()
	hl.exec_cmd("uwsm app -- noctalia")
end)
