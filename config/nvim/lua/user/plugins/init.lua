return {
  "nvim-lua/plenary.nvim",
  { "tpope/vim-sleuth",     event = "VeryLazy" },
  { "ThePrimeagen/harpoon", opts = { mark_branch = true } },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = { diff_opts = { vertical = false } },
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
  },
  -- Appearance related plugins
  "kyazdani42/nvim-web-devicons",
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
}
