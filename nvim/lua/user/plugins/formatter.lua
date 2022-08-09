require("formatter").setup({
  filetype = {
    lua = { require("formatter.filetypes.lua").stylua },
    typescript =  { require("formatter.filetypes.typescript").prettier }
  }
})
