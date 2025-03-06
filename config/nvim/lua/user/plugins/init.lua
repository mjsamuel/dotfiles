return {
  "nvim-lua/plenary.nvim",
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      diff_opts = { vertical = false },
      preview_config = { border = 'rounded', },
    },
  },
  {
    "kylechui/nvim-surround",
    keys = { { "ys" }, { "cs" }, { "ds" }, { "S", mode = "v" } },
    opts = {},
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
    },
  },
  -- Appearance related plugins
  "kyazdani42/nvim-web-devicons",
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    cmd = "RenderMarkdown",
    opts = {
      enabled = false, -- disable render by default
      file_types = { "markdown", "copilot-chat" },
      overrides = {
        filetype = {
          ["copilot-chat"] = {
            heading = { position = "right" },
            render_modes = { 'i', 'n', 'c', 't' },
            anti_conceal = { enabled = false }
          },
        }
      }
    }
  }
}
