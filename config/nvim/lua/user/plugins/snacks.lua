local M = {
  "folke/snacks.nvim",
  opts = {} ---@type snacks.Config
}

M.opts.picker = {
  enabled = true,
  layout = {
    hidden = { "preview" },
    preset = function()
      return vim.o.columns >= 120 and "minimal" or "minimal_vertical"
    end,
  },
  win = {
    input = {
      keys = { ["<Tab>"] = { "toggle_preview", mode = { "i", "n" } } }
    }
  },
  layouts = {
    minimal = {
      layout = {
        backdrop = false,
        width = 0.8,
        min_width = 100,
        height = 0.5,
        border = "rounded",
        box = "horizontal",
        {
          box = "vertical",
          { win = "input", height = 1, border = "bottom" },
          { win = "list" },
        },
        { win = "preview", width = 0.6, border = "left" },
      }
    },
    minimal_vertical = {
      layout = {
        backdrop = false,
        width = 0.8,
        height = 0.7,
        border = "rounded",
        box = "vertical",
        { win = "input",   height = 1,   border = "bottom" },
        { win = "list", },
        { win = "preview", height = 0.7, border = "top" },
      },
    }
  }
}

return M
