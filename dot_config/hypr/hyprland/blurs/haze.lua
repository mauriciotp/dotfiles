-- haze: difuso, com brilho perolado que muda de cor (HyDE)
hl.config({ decoration = { blur = {
	variant = "haze", size = 10, passes = 3, brightness = 1.01, contrast = 0.9, vibrancy = 0.21,
	haze = { intensity = 0.38, iridescence = 0.78 },
} } })
