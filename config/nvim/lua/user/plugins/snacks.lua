local M = {
  "folke/snacks.nvim",
  opts = {}
}

local layouts = {
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
  }
}

-- Function to toggle fullscreen layout
local prev_layout = nil
local function toggle_fullscreen_layout(picker)
  local is_fullscreen = picker.layout.opts.fullscreen
  local is_preview_hidden = picker.layout:is_hidden("preview")
  local next_layout = nil
  if (is_fullscreen) then
    next_layout = { layout = prev_layout }
  else
    prev_layout = picker.layout.opts.layout
    next_layout = {
      fullscreen = true,
      layout = vim.tbl_deep_extend("force", prev_layout, {
        width = nil,
        height = nil,
        border = "none",
      })
    }
  end
  picker:set_layout(next_layout)
  picker:toggle("preview", { enable = not is_preview_hidden })
end

M.opts.picker = {
  layout = {
    hidden = { "preview" },
    preset = function()
      local height = vim.o.lines + 1 -- accounting for tmux statusline
      local width = vim.o.columns
      local aspect_ratio = math.floor(width / height)
      if (aspect_ratio <= 1) then
        return "minimal_vertical"
      end
      return "minimal"
    end,
  },
  sources = {
    grep = {
      layout = {
        hidden = {}, -- show preview by default
      }
    },
    grep_word = {
      layout = {
        hidden = {}, -- show preview by default
      }
    },
    diagnostics = {
      win = {
        input = {
          keys = {
            ["<C-t>"] = { "trouble_open_diagnostics", mode = { "i", "n" } },
          }
        }
      }
    },
  },
  actions = {
    trouble_open = function(picker)
      require('trouble.sources.snacks').actions.trouble_open.action(picker)
    end,
    trouble_open_diagnostics = function(picker)
      require('trouble').open("diagnostics")
      picker:close()
    end,
    toggle_fullscreen = toggle_fullscreen_layout
  },
  win = {
    input = {
      keys = {
        ["<Tab>"] = { "toggle_preview", mode = { "i", "n" } },
        ["<C-space>"] = { "toggle_live", mode = { "i", "n" } },
        ["<C-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
        ["<C-f>"] = { "toggle_fullscreen", mode = { "i", "n" } },
        ["<C-t>"] = { "trouble_open", mode = { "i", "n" } },
        ["<C-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
      },
    }
  },
  layouts = layouts
}

return M
