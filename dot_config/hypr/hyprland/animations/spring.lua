-- KoolDots (Spring-curves, LinuxBeginnings/Hyprland-Dots): física de mola em
-- vez de bézier. O ritmo vem da rigidez (stiffness) e do amortecimento
-- (damping); o speed quase não pesa. Desde a 0.56 a mola anda pelo tempo real,
-- então valores "moles" (mass 2, stiffness 15–30) ficam lentos demais.
-- As fontes escrevem "dampening"; a wiki e o Hyprland 0.57 usam "damping".
hl.curve("spring_fast", { type = "spring", mass = 1, stiffness = 280, damping = 26 })
hl.curve("spring_slow", { type = "spring", mass = 1, stiffness = 160, damping = 24 })

-- janelas surgem do centro, com um pouco de mola
hl.animation({ leaf = "windows", enabled = true, speed = 1, spring = "spring_fast" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 1, spring = "spring_fast", style = "popin 50%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 1, spring = "spring_fast", style = "popin" })

hl.animation({ leaf = "border", enabled = true, speed = 1, spring = "spring_slow" })
hl.animation({ leaf = "borderangle", enabled = false })
hl.animation({ leaf = "fade", enabled = true, speed = 1, spring = "spring_slow" })
hl.animation({ leaf = "zoomFactor", enabled = true, speed = 6, spring = "spring_fast" })

-- painéis do Noctalia (layers)
hl.animation({ leaf = "layersIn", enabled = true, speed = 3, spring = "spring_fast", style = "slide" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 1.6, spring = "spring_fast", style = "slide" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 2, spring = "spring_fast" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.6, spring = "spring_fast" })

hl.animation({ leaf = "workspaces", enabled = true, speed = 1, spring = "spring_slow", style = "slide" })
-- especiais (scratchpad, música, btop) descem por cima da tela
hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 1, spring = "spring_slow", style = "slidevert 80%" })
