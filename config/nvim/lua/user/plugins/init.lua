return {
  "nvim-lua/plenary.nvim",
  "kyazdani42/nvim-web-devicons",
  { "tpope/vim-fugitive", cmd = "Git" },
  {
    "ThePrimeagen/harpoon",
    opts = { mark_branch = true },
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
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {},
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      progress = {
        display = {
          done_icon = "",
          done_style = "Comment",
          progress_style = "Comment",
          group_style = "Comment",
          icon_style = "Comment",
        },
      },
      notification = { window = { winblend = 0 } },
    },
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
  {
    "luukvbaal/statuscol.nvim",
    lazy = false,
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        setopt = true,
        segments = {
          { sign = { name = { "Diagnostic", "Dap*" }, auto = false } },
          { text = { builtin.lnumfunc, " " } },
          { sign = { namespace = { "gitsigns" } } },
        },
      })
    end,
  },
}
