local M = {
  "lukas-reineke/indent-blankline.nvim",
  event = "BufReadPre",
}

function M.config()
  require("indent_blankline").setup({
    show_current_context = true,
    show_current_context_start = true,
    disable_with_nolist = true,
  })
end

return M