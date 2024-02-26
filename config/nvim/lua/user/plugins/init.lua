return {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",
  {
    "ThePrimeagen/harpoon",
    opts = { mark_branch = true },
  },
  {
    "kylechui/nvim-surround",
    keys = { { "ys" }, { "cs" }, { "ds" }, { "S", mode = "v" } },
    opts = {},
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {},
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "numToStr/Comment.nvim",
    keys = { { "gc" }, { "gc", mode = "v" } },
    opts = {},
  },
  { "prichrd/netrw.nvim", lazy = false, opts = {} },
}
