-- Curvas e animações.

-- Curva de aceleração: começa rápido e assenta suave
hl.curve("smooth", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.0 } } })

-- speed em décimos de segundo (4 = 0,4 s)
hl.animation({ leaf = "global", enabled = true, speed = 6, bezier = "smooth" })
hl.animation({ leaf = "windows", enabled = true, speed = 4, bezier = "smooth", style = "popin 80%" })
hl.animation({ leaf = "fade", enabled = true, speed = 3, bezier = "smooth" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "smooth", style = "slide" })
-- workspaces especiais (scratchpad, música) descem por cima da tela
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 3, bezier = "smooth", style = "slidevert" })
