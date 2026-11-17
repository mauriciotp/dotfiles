-- acrylic: vidro líquido, com lente nas bordas e separação de cor (HyDE)
hl.config({ decoration = { blur = {
	variant = "acrylic", size = 10, passes = 3,
	brightness = 1.02, contrast = 0.94, vibrancy = 0.24, noise = 0.008,
	acrylic = { tint = "0x12D5F1FF", refraction = 26.0, aberration = 0.03, bulb = 52.0, clarity = 0.85 },
} } })
