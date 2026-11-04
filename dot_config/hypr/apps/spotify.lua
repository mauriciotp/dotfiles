-- Spotify: workspace especial "music" (SUPER+SHIFT+M abre e fecha por cima de tudo).
-- O spotify-launcher roda via XWayland e a janela já nasce com a classe "Spotify".
-- Se um dia mudar para Wayland nativo e nascer sem classe, troque o match por
-- { initial_title = "^Spotify" }.
hl.window_rule({ name = "music", match = { class = "^[Ss]potify$" }, workspace = "special:music silent" })
