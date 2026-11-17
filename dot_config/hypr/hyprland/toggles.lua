-- Toggles, ligados e desligados fora da config (Omarchy).
-- O estado fica em ~/.local/state/hypr/, fora do chezmoi, e quem mexe nele é o
-- ~/.local/bin/hypr-toggle (SUPER+CTRL+T), que recarrega a config em seguida:
--   toggles/<nome>  arquivo vazio = toggle ligado; carrega hyprland/toggles/<nome>.lua
-- Por arquivo, e não por hl.config na hora: o efeito sobrevive ao reload
-- (SUPER+CTRL+R, tv-toggle). Carrega depois de decoration, animações, regras e
-- apps, para vencer o que eles definem.
local state = (os.getenv("XDG_STATE_HOME") or (os.getenv("HOME") .. "/.local/state")) .. "/hypr"

-- só nomes simples, e só os que existem na config: uma flag velha ou estranha
-- é ignorada em vez de quebrar o reload
local function load(dir, name)
	if not (name and name:match("^[%w_-]+$")) then
		return false
	end
	local module = "hyprland." .. dir .. "." .. name
	if not package.searchpath(module, package.path) then
		return false
	end
	-- roda de novo a cada reload, mesmo se o require guardou o módulo (Omarchy,
	-- require_all com reload = true)
	package.loaded[module] = nil
	require(module)
	return true
end

-- toggles ligados, em ordem alfabética (window-opaque vence window-glassy)
local list = io.popen("find '" .. state .. "/toggles' -maxdepth 1 -type f -printf '%f\\n' 2>/dev/null | sort")
if list then
	for name in list:lines() do
		load("toggles", name)
	end
	list:close()
end
