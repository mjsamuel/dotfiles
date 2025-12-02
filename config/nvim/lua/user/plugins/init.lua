return {
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
  {
    "folke/ts-comments.nvim",
    ft = { "typescriptreact", "javascriptreact" },
    opts = {},
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
  },
  -- Appearance related plugins
  "kyazdani42/nvim-web-devicons",
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
}
