local M = { "mhartington/formatter.nvim" }

function M.config()
  require("formatter").setup({
    filetype = {
      lua = { require("formatter.filetypes.lua").stylua },
      typescript = { require("formatter.filetypes.typescript").prettier },
      typescriptreact = { require("formatter.filetypes.typescriptreact").prettier },
      javascript = { require("formatter.filetypes.javascript").prettier },
      javascriptreact = { require("formatter.filetypes.javascriptreact").prettier },
      html = { require("formatter.filetypes.html").prettier },
      json = { require("formatter.filetypes.json").prettier },
      markdown = { require("formatter.filetypes.markdown").prettier },
    },
  })
end

return M
