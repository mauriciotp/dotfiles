return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      -- Drop the "--dialect=ansi" the LazyVim extra forces, so sqlfluff
      -- reads dialect/templater from the project's .sqlfluff instead.
      opts.formatters.sqlfluff = {
        args = { "format", "-" },
      }
    end,
  },
}
