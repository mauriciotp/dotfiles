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

-- ===== Para experimentar =====
-- Dois conjuntos das referências. Para testar um: comente as animações acima,
-- descomente o bloco e recarregue (SUPER+CTRL+R). O11, S9

-- Caelestia: curvas do Material Design; painéis e o especial deslizam com fade
-- hl.curve("specialWorkSwitch", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
-- hl.curve("emphasizedAccel", { type = "bezier", points = { { 0.3, 0 }, { 0.8, 0.15 } } })
-- hl.curve("emphasizedDecel", { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
-- hl.curve("standard", { type = "bezier", points = { { 0.2, 0 }, { 0, 1 } } })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "emphasizedDecel", style = "slide" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "emphasizedAccel", style = "slide" })
-- hl.animation({ leaf = "fadeLayers", enabled = true, speed = 5, bezier = "standard" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 5, bezier = "emphasizedDecel" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "emphasizedAccel" })
-- hl.animation({ leaf = "windowsMove", enabled = true, speed = 6, bezier = "standard" })
-- hl.animation({ leaf = "workspaces", enabled = true, speed = 5, bezier = "standard" })
-- hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 4, bezier = "specialWorkSwitch", style = "slidefadevert 15%" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 6, bezier = "standard" })
-- hl.animation({ leaf = "fadeDim", enabled = true, speed = 6, bezier = "standard" })
-- hl.animation({ leaf = "border", enabled = true, speed = 6, bezier = "standard" })

-- Omarchy: rápidas (0,1 a 0,3 s), e a troca de workspace sem animação
-- hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
-- hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
-- hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
-- hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
-- hl.animation({ leaf = "global", enabled = true, speed = 8, bezier = "default" })
-- hl.animation({ leaf = "border", enabled = true, speed = 4.31, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windows", enabled = true, speed = 3.03, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "windowsIn", enabled = true, speed = 3.28, bezier = "easeOutQuint", style = "popin 87%" })
-- hl.animation({ leaf = "windowsOut", enabled = true, speed = 1.19, bezier = "linear", style = "popin 87%" })
-- hl.animation({ leaf = "fadeIn", enabled = true, speed = 1.38, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeOut", enabled = true, speed = 1.17, bezier = "almostLinear" })
-- hl.animation({ leaf = "fade", enabled = true, speed = 2.42, bezier = "quick" })
-- hl.animation({ leaf = "fadeSwitch", enabled = false })
-- hl.animation({ leaf = "layers", enabled = true, speed = 3.05, bezier = "easeOutQuint" })
-- hl.animation({ leaf = "layersIn", enabled = true, speed = 3.2, bezier = "easeOutQuint", style = "fade" })
-- hl.animation({ leaf = "layersOut", enabled = true, speed = 1.2, bezier = "linear", style = "fade" })
-- hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 1.43, bezier = "almostLinear" })
-- hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.11, bezier = "almostLinear" })
-- hl.animation({ leaf = "workspaces", enabled = false })
