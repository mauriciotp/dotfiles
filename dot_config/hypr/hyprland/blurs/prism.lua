-- prism: máscara de refração em triângulos (HyDE, sem o glow que ele liga junto)
hl.config({ decoration = { blur = {
	variant = "prism", size = 10, passes = 2, vibrancy = 0.26,
	glass = { refraction = 20.0, roughness = 0.95, size = 38.0 },
} } })
