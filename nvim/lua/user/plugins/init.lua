return {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",
  "ThePrimeagen/refactoring.nvim",
  {
    "SmiteshP/nvim-navic",
    config = function()
      vim.g.navic_silence = true
      require("nvim-navic").setup({ separator = " ", highlight = true, depth_limit = 5 })
    end,
  },
  { "tpope/vim-fugitive", cmd = "Git" },
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
          "neo-tree",
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
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    dependencies = { "MunifTanjim/nui.nvim" },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = {
          position = "left",
        },
      })
    end,
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
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
    "phelipetls/jsonpath.nvim",
    ft = "json",
    keys = {
      {
        "yj",
        function()
          return vim.fn.setreg('"', require("jsonpath").get())
        end,
      },
    },
  },
  {
    "ggandor/leap.nvim",
    keys = { "s", "S" },
    config = function()
      require("leap").add_default_mappings()
    end,
  },
}
