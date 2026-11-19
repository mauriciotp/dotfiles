-- LSP: sem as inlay hints (os tipos e nomes de parâmetro que o servidor
-- escreve no meio da linha). Opção do LazyVim no nvim-lspconfig; para ver as
-- dicas por um momento: <leader>uh.
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
