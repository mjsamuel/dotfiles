return {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",
  {
    "ThePrimeagen/refactoring.nvim",
    config = function()
      require('refactoring').setup({})
      require("telescope").load_extension("refactoring")
    end,
  },
  { "tpope/vim-fugitive", cmd = "Git" },
  { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
  {
    "kylechui/nvim-surround",
    keys = { { "ys" }, { "cs" }, { "ds" }, { "S", mode = "v" } },
    config = true,
  },
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({
        delay = 200,
        filetypes_denylist = {
          "TelescopePrompt",
          "fugitiveblame",
          "lazy",
          "mason",
          "NvimTree",
        },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = true,
  },
  {
    "Shatur/neovim-session-manager",
    event = "VeryLazy",
    config = function()
      require("session_manager").setup({
        autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
      })
    end,
  },
  {
    "ggandor/leap.nvim",
    keys = { "s", "S" },
    config = function()
      require("leap").add_default_mappings()
    end,
  },
  {
    "j-hui/fidget.nvim",
    config = {
      text = {
        spinner = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
        done = "",
      },
    },
    event = "LspAttach",
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    config = {
      view = {
        side = "right",
      },
    },
  },
}
