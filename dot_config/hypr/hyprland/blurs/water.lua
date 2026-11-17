-- water: ondas na água que seguem o cursor (HyDE). Simulação: custa GPU
hl.config({ decoration = { blur = {
	variant = "water", size = 9, passes = 2,
	water = { speed = 0.82, strength = 32.0, radius = 24.0, damping = 0.94, duration = 14.0 },
} } })
