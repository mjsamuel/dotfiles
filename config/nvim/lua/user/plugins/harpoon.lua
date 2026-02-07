vim.pack.add({
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2", },
  "https://github.com/nvim-lua/plenary.nvim"
})

require("harpoon").setup({
  settings = {
    save_on_toggle = true,
    sync_on_ui_close = true,
  },
  default = {
    BufLeave = function()
      -- center when moving to another buffer
      vim.schedule(function() vim.cmd("normal! zz") end)
    end
  }
})
