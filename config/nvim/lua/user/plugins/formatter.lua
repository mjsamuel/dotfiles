local M = {
  "mhartington/formatter.nvim",
  cmd = "Format",
}

function M.config()
  require("formatter").setup({
    filetype = {
      html = { require("formatter.filetypes.html").prettierd },
      javascript = { require("formatter.filetypes.javascript").prettierd },
      javascriptreact = { require("formatter.filetypes.javascriptreact").prettierd },
      json = { require("formatter.filetypes.json").prettierd },
      lua = { require("formatter.filetypes.lua").stylua },
      markdown = { require("formatter.filetypes.markdown").markdownlint },
      python = { require("formatter.filetypes.python").autopep8 },
      typescript = { require("formatter.filetypes.typescript").prettierd },
      typescriptreact = { require("formatter.filetypes.typescriptreact").prettierd },
      sql = {
        {
          exe = "sql-formatter",
          args = {
            "--config",
            "$HOME/Developer/dotfiles/other/sql-formatter.json",
          },
          stdin = true,
        },
      },
      sh = { require("formatter.filetypes.sh").shfmt },
    },
  })
end

return M
