local M = {
  "folke/snacks.nvim",
  opts = {}
}

---@type snacks.picker.Config
M.opts.picker = {
  enabled = true,
  ui_select = true,
  layout = "minimal",
  win = {
    input = {
      keys = {
        ["<Tab>"] = { "toggle_preview", mode = { "i", "n" } },
      }
    }
  },
  layouts = {
    minimal = {
      layout = {
        backdrop = false,
        width = 0.8,
        min_width = 120,
        height = 0.75,
        border = "rounded",
        box = "horizontal",
        {
          box = "vertical",
          border = "none",
          { win = "input", height = 1, border = "bottom" },
          { win = "list",  border = "none" },
        },
        { win = "preview", width = 0.6, border = "left" },
      },
    }
  }
}

return M
