local M = {
  "folke/snacks.nvim",
  opts = {}
}

local previous_layout = nil
M.opts.picker = {
  sources = {
    grep = { layout = { hidden = {}, } },
    grep_word = { layout = { hidden = {}, } }
  },
  actions = {
    toggle_fullscreen = function(picker)
      local is_fullscreen = picker.layout.opts.fullscreen
      local preview_hidden = picker.layout:is_hidden("preview")
      local layout
      if (is_fullscreen) then
        layout = { layout = previous_layout }
      else
        layout = "minimal_fullscreen"
        previous_layout = picker.layout.opts.layout
      end
      picker:set_layout(layout)
      picker:toggle("preview", { enable = not preview_hidden })
    end
  },
  win = {
    input = {
      keys = {
        ["<Tab>"] = { "toggle_preview", mode = { "i", "n" } },
        ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
        ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
        ["<C-z>"] = { "toggle_fullscreen", mode = { "i", "n" } },
        ["<C-space>"] = { "toggle_live", mode = { "i", "n" } },
      },
    }
  },
  layout = {
    hidden = { "preview" },
    preset = function()
      if (vim.o.columns <= 100 or vim.o.lines <= 25) then
        return "minimal_fullscreen"
      elseif (vim.o.columns > vim.o.lines) then
        return "minimal"
      else
        return "minimal_vertical"
      end
    end,
  },
  layouts = {
    minimal = {
      layout = {
        backdrop = false,
        width = 0.8,
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
    },
    minimal_fullscreen = {
      fullscreen = true,
      layout = {
        backdrop = false,
        border = "none",
        box = "horizontal",
        {
          box = "vertical",
          { win = "input", height = 1, border = "bottom" },
          { win = "list" },
        },
        { win = "preview", width = 0.6, border = "left" },
      }
    },
  }
}

return M
