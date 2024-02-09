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

    "luukvbaal/statuscol.nvim",
    event = "BufReadPre",
    branch = "0.10",
    config = function()
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        setopt = true,
        ft_ignore = { "lazy", "harpoon" },
        segments = {
          { sign = { namespace = { "diagnostic*" }, auto = false } },
          { text = { builtin.lnumfunc, " " } },
          { sign = { namespace = { "gitsigns" }, auto = false } },
        },
      })
    end,
  },
  { "shortcuts/no-neck-pain.nvim", cmd = "NoNeckPain", opts = {} },
}
