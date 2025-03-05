return {
  "nvim-lua/plenary.nvim",
  { "tpope/vim-sleuth",  event = "VeryLazy" },
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
    "pmizio/typescript-tools.nvim",
    ft = { "typescript", "typescriptreact" },
    opts = {
      expose_as_code_action = "all",
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
    },
  },
  {
    "chrisgrieser/nvim-early-retirement",
    config = true,
    event = "VeryLazy",
    opts = { retirementAgeMins = 20 },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
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
