-- heat_shimmer: tremor de calor, com separação de cor (HyDE, sem o motion
-- blur que ele liga junto). Animada: custa GPU
hl.config({ decoration = { blur = {
	variant = "heat_shimmer", size = 9, passes = 2,
	glass = { refraction = 20.0, roughness = 0.75, size = 42.0 },
	heat_shimmer = { speed = 1.2 },
} } })
