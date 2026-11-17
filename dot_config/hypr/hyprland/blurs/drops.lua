-- drops: chuva escorrendo num vidro (HyDE). Animada: custa GPU
hl.config({ decoration = { blur = {
	variant = "drops", size = 10, passes = 2, contrast = 0.95, noise = 0.015,
	glass = { refraction = 20.0, roughness = 0.9, size = 44.0 },
	drops = { speed = 3.2 },
} } })
