-- Funções comuns aos atalhos (hyprland/keybinds.lua) e às regras
-- (hyprland/rules.lua e hyprland/apps/).
local F = {}

-- Caminho absoluto: o PATH do Hyprland não inclui ~/.local/bin
F.bin = os.getenv("HOME") .. "/.local/bin/"

-- ===== Atalhos =====

-- bind(teclas, descrição, ação, flags opcionais)
--   teclas     um texto ("SUPER + Q") ou uma lista, para a mesma ação em várias teclas
--   descrição  obrigatória: o SUPER+F1 lista todas (script ~/.local/bin/keybinds).
--              Use false para uma bind interna, que não deve aparecer na cola.
--   ação       um dispatcher (hl.dsp...), uma função, ou um texto, que vira comando
function F.bind(keys, desc, action, flags)
	if desc == nil then
		error("bind without description: " .. tostring(keys), 2)
	end
	if type(action) == "string" then
		action = hl.dsp.exec_cmd(action)
	end
	if type(keys) ~= "table" then
		keys = { keys }
	end
	for _, key in ipairs(keys) do
		-- uma cópia das flags por tecla, para a descrição não vazar entre binds
		local f = {}
		for k, v in pairs(flags or {}) do
			f[k] = v
		end
		if desc then
			f.description = desc
		end
		hl.bind(key, action, f)
	end
end

-- Abre sempre uma janela nova (dentro do uwsm vira unidade do systemd)
function F.run(cmd)
	return hl.dsp.exec_cmd("uwsm app -- " .. cmd)
end

-- Abre ou foca um app de janela única (~/.local/bin/launch-or-focus)
function F.app(class, cmd)
	return hl.dsp.exec_cmd(string.format("%slaunch-or-focus '%s' %s", F.bin, class, cmd))
end

-- Comando do IPC do Noctalia (docs.noctalia.dev → IPC)
function F.ipc(cmd)
	return hl.dsp.exec_cmd("noctalia msg " .. cmd)
end

-- O programa existe? Para criar o atalho de um app opcional só se ele estiver
-- instalado (Omarchy): a cola do SUPER+F1 nunca lista atalho morto.
-- Procura no PATH e em ~/.local/bin, sem abrir um shell.
function F.cmd_present(name)
	local path = (os.getenv("PATH") or "") .. ":" .. F.bin
	for dir in path:gmatch("[^:]+") do
		local f = io.open(dir .. "/" .. name, "r")
		if f then
			f:close()
			return true
		end
	end
	return false
end

-- ===== Regras de janela =====

-- window(nome, match, propriedades): regra de um app só.
-- O match pode ser só a classe, como texto. Toda regra tem nome: aparece no
-- hyprctl e dá para ligar e desligar por código.
function F.window(name, match, props)
	if type(match) == "string" then
		match = { class = match }
	end
	local rule = { name = name, match = match }
	for k, v in pairs(props) do
		rule[k] = v
	end
	return hl.window_rule(rule)
end

-- Tags (Caelestia): a lista diz quem recebe a tag; a definição diz o que a tag faz.
--   tagged_rule("float_60_75", { "^xdg-desktop-portal-gtk$" }, "class")
--   create_tag("float_60_75", { float = true, center = true, size = ... })
-- A definição vem depois de todas as listas da mesma tag.
local tag_count = {}

-- Com "field", matches é uma lista de textos (o valor daquele campo);
-- sem, uma lista de tabelas de match.
function F.tagged_rule(tag, matches, field)
	for _, match in ipairs(matches) do
		if field then
			match = { [field] = match }
		end
		tag_count[tag] = (tag_count[tag] or 0) + 1
		hl.window_rule({ name = "tag-" .. tag .. "-" .. tag_count[tag], match = match, tag = "+" .. tag })
	end
end

function F.create_tag(tag, props)
	return F.window(tag, { tag = tag }, props)
end

-- ===== Tamanhos =====

-- Tamanho em % da tela em foco, para window.resize (Caelestia)
function F.resize_by_screen(x_percent, y_percent)
	local m = hl.get_active_monitor()
	if not m then
		return nil
	end
	return {
		x = math.floor(m.width / m.scale * x_percent / 100),
		y = math.floor(m.height / m.scale * y_percent / 100),
		relative = false,
	}
end

-- Redimensiona a janela ativa em % do tamanho dela (Caelestia): o passo
-- acompanha o tamanho da janela, em vez de um número fixo de pixels.
function F.resize_active_window(x_percent, y_percent)
	return function()
		local w = hl.get_active_window()
		if not (w and w.size) then
			return
		end
		hl.dispatch(hl.dsp.window.resize({
			x = math.floor(w.size.x * x_percent / 100),
			y = math.floor(w.size.y * y_percent / 100),
			relative = true,
		}))
	end
end

-- A janela tem a tag? (as tags dinâmicas vêm com * no fim)
function F.has_tag(w, tag)
	local tags = w and w.tags or {}
	if type(tags) == "string" then
		tags = { tags }
	end
	for _, t in ipairs(tags) do
		if t == tag or t == tag .. "*" then
			return true
		end
	end
	return false
end

-- ===== Workspaces especiais =====

-- Texto vira regex exata: "md.obsidian.Obsidian" → "^(md\.obsidian\.Obsidian)$"
function F.exact_regex(names)
	local escaped = {}
	for i, name in ipairs(names) do
		escaped[i] = (name:gsub("[%^%$%(%)%%%.%[%]%*%+%-%?%{%}|\\]", "\\%0"))
	end
	return "^(" .. table.concat(escaped, "|") .. ")$"
end

local function has_class(app, class)
	for _, c in ipairs(app.classes or {}) do
		if c == class then
			return true
		end
	end
	return false
end

-- toggle(nome): ação da tecla de um especial (Caelestia, utils/functions.lua).
--   fechado, ou outro especial aberto  mostra este; abre os apps que não estão
--                                      rodando e traz os que estão em outro lugar
--   este já aberto                     esconde
-- Os apps de cada especial ficam em variables.lua (toggles).
function F.toggle(name)
	local vars = require("variables")
	return function()
		local open = hl.get_active_special_workspace()
		local target = "special:" .. name
		if open and open.name == target then
			hl.dispatch(hl.dsp.workspace.toggle_special(name))
			return
		end
		hl.dispatch(hl.dsp.focus({ workspace = target }))
		local windows = hl.get_windows() or {}
		local brought -- a última janela trazida de outro workspace
		for _, app in pairs(vars.toggles[name] or {}) do
			local running = false
			for _, w in ipairs(windows) do
				if has_class(app, w.class) then
					running = true
					local here = w.workspace and w.workspace.name == target
					if app.move and not here then
						hl.dispatch(hl.dsp.window.move({ window = "address:" .. w.address, workspace = target, follow = false }))
						brought = w.address
					end
				end
			end
			if not running and app.command then
				hl.dispatch(F.run(app.command))
			end
		end
		-- o especial abriu antes de a janela chegar (vazio, sem nada para focar):
		-- foca a janela trazida, senão o teclado não vai para ela
		if brought then
			hl.dispatch(hl.dsp.focus({ window = "address:" .. brought }))
		end
	end
end

-- Tecla do scratchpad: com specialWsCloseAny, fecha o especial aberto (qualquer
-- um); sem especial aberto, mostra o scratchpad.
function F.toggle_scratch()
	local vars = require("variables")
	local open = hl.get_active_special_workspace()
	if vars.specialWsCloseAny and open then
		hl.dispatch(hl.dsp.workspace.toggle_special((open.name:gsub("^special:", ""))))
	else
		hl.dispatch(hl.dsp.workspace.toggle_special("scratch"))
	end
end

return F
