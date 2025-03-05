return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  opts = {
    settings = {
      save_on_toggle = true,
      sync_on_ui_close = true,
    },
    default = {
      BufLeave = function()
        -- center when moving to another buffer
        vim.schedule(function()
          vim.cmd("normal! zz")
        end)
      end
    }
  }
}
