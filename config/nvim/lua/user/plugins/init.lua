return {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",
  { "tpope/vim-fugitive", cmd = "Git" },
  {
    "ThePrimeagen/harpoon",
    opts = {
      mark_branch = true,
    },
  },
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
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    opts = { signs = { error = "", warning = "", hint = "", information = "", other = "" } },
  },
  {
    "stevearc/oil.nvim",
    cmd = "Oil",
    opts = {
      default_file_explorer = true,
      view_options = { show_hidden = true },
    },
  },
}
