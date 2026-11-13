-- Animações: um conjunto por arquivo em hyprland/animations/, escolhido em
-- variables.lua (animations). Para trocar: mude o nome lá e recarregue
-- (SUPER+CTRL+R). Formato do Mainstream (fork do end-4), que guarda os
-- conjuntos em arquivos separados. O11, S9
--   smooth     o próprio (padrão)
--   caelestia  curvas do Material Design; painéis e o especial deslizam com fade
--   omarchy    rápidas (0,1 a 0,3 s), e a troca de workspace sem animação
require("hyprland.animations." .. require("variables").animations)
