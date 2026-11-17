-- fluid_jar: líquido num pote, que balança quando a janela mexe (HyDE, sem o
-- wobble que ele liga junto). Simulação: custa GPU
hl.config({ decoration = { blur = {
	variant = "fluid_jar", size = 9, passes = 2, contrast = 0.93,
	fluid_jar = { color = "0xCC4AA9FF", speed = 4.0, fill_amount = 0.56, turbulence = 1.3, distortion = 8.5, mass = 1.5, precision = 2.0 },
} } })
