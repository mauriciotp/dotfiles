-- aurora: faixas de luz animadas, como aurora boreal (HyDE). Animada: custa GPU
hl.config({ decoration = { blur = {
	variant = "aurora", size = 9, passes = 2, vibrancy = 0.22,
	glass = { refraction = 18.0, roughness = 0.82, size = 48.0 },
	aurora = { color1 = "0x2CF4A7FF", color2 = "0x8A57FFFF", intensity = 0.42, speed = 1.3 },
} } })
