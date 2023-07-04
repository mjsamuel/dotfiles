return {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",
  "nvim-telescope/telescope-file-browser.nvim",
  {
    "ThePrimeagen/harpoon",
    opts = {
      mark_branch = true,
    }
  },
  {
    "ThePrimeagen/refactoring.nvim",
    config = true,
  },
  { "tpope/vim-fugitive",         cmd = "Git" },
  { "nvim-treesitter/playground", cmd = "TSPlaygroundToggle" },
  {
    "kylechui/nvim-surround",
    keys = { { "ys" }, { "cs" }, { "ds" }, { "S", mode = "v" } },
    opts = {
      surrounds = {
        ["("] = { add = { "(", ")" } },
        ["{"] = { add = { "{", "}" } },
        ["["] = { add = { "[", "]" } },
      },
    },
  },
  {
    "RRethy/vim-illuminate",
    event = "BufReadPost",
    config = function()
      require("illuminate").configure({
        delay = 200,
        filetypes_denylist = { "TelescopePrompt", "fugitiveblame", "lazy", "mason" },
      })
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = { trouble = false },
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
    branch = "legacy",
    opts = {
      text = {
        spinner = { "⣷", "⣯", "⣟", "⡿", "⢿", "⣻", "⣽", "⣾" },
        done = "",
      },
    },
    event = "LspAttach",
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      local Rule = require("nvim-autopairs.rule")
      autopairs.setup()
      autopairs.add_rules({ Rule("{{", "  }", "html"):set_end_pair_length(2) })
    end,
  },
  {
    "numToStr/Comment.nvim",
    keys = { { "gc" }, { "gc", mode = "v" } },
    dependencies = "JoosepAlviste/nvim-ts-context-commentstring",
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufReadPre",
    config = function()
      require("indent_blankline").setup({
        show_current_context = true,
        show_current_context_start = true,
        disable_with_nolist = true,
      })
    end,
  },
  {
    "folke/trouble.nvim",
    opts = { signs = { error = "", warning = "", hint = "", information = "", other = "" } },
  },
}
