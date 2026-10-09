-- Claude Code no nvim: claudecode.nvim (protocolo, menções, diffs) + lua/claude/ (Claude no
-- tmux, prompts, placeholders, Ask/Select). Este arquivo só configura; a lógica está em
-- lua/claude/ e a documentação dos atalhos, no README.

return {
  {
    "coder/claudecode.nvim",
    -- carrega logo após o startup: o servidor sobe (para o /ide achar este nvim) e os
    -- comandos :ClaudeCode* existem antes de qualquer atalho
    event = "VeryLazy",
    opts = function()
      return {
        terminal = {
          -- no tmux, o Claude roda num pane (lua/claude/tmux.lua); fora dele, no terminal do snacks
          provider = vim.env.TMUX and require("claude.tmux").provider or "snacks",
        },
        -- após um envio, o plugin chama provider.open() -> foca o pane do Claude
        focus_after_send = true,
        -- tempo para o Claude subir e conectar antes de descartar menções na fila
        connection_timeout = 20000,
        queue_timeout = 20000,
        diff_opts = {
          layout = "vertical",
          open_in_new_tab = true, -- diff ocupa a tela inteira; o Claude está no pane tmux
        },
      }
    end,
    config = function(_, opts)
      require("claudecode").setup(opts)
      require("claude").setup()
    end,
    -- função = substitui por inteiro os atalhos do extra ai.claudecode do LazyVim;
    -- todos são gerados em lua/claude/init.lua (ações) e lua/claude/prompts.lua (prompts)
    keys = function()
      return require("claude").keys()
    end,
  },

  -- Alt+a dentro de um picker do snacks (files/grep/buffers) anexa os itens ao Claude
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        actions = {
          claude_send = function(picker)
            local items = picker:selected({ fallback = true })
            picker:close()
            for _, item in ipairs(items) do
              if item.file then
                require("claudecode").send_at_mention(Snacks.picker.util.path(item), nil, nil, "snacks_picker")
              end
            end
          end,
        },
        win = {
          input = {
            keys = {
              ["<a-a>"] = { "claude_send", mode = { "n", "i" }, desc = "Send to Claude" },
            },
          },
        },
      },
    },
  },

  -- Statusline: ícone do Claude, colorido quando conectado a este nvim
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 1, require("claude").statusline)
    end,
  },
}
