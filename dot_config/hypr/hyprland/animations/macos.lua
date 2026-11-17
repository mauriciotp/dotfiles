-- HyDE (macos.lua): janelas abrem e fecham com mola (popin 90%), e
-- workspaces e especiais deslizam com fade. Sem a escala de velocidade do
-- HyDE (hyde.config.anim.duration_scale); "damping" no lugar de "dampening".
hl.curve("macOpen", { type = "spring", mass = 1, stiffness = 110, damping = 16 })
hl.curve("macBounce", { type = "spring", mass = 1, stiffness = 80, damping = 10 })
hl.curve("macSmooth", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1.0 } } })

-- fades (o ramo "fade" cobre todos os fade*)
hl.animation({ leaf = "fade", enabled = true, speed = 8, bezier = "default" })

hl.animation({ leaf = "windows", enabled = true, speed = 8, spring = "macOpen", style = "popin 90%" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 8, spring = "macOpen", style = "popin 90%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 7, spring = "macBounce", style = "popin 90%" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 5, bezier = "macSmooth", style = "slide" })

hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "default" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 7, bezier = "default" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefade 20%" })
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 6, bezier = "macSmooth", style = "slidefadevert 20%" })
