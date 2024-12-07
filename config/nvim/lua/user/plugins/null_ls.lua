local M = {
  "nvimtools/none-ls.nvim",
  event = "BufReadPre",
}

M.config = function()
  require("mason-null-ls").setup({ handlers = {} })
end

return M
