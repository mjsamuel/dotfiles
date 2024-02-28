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
  {
    "luukvbaal/statuscol.nvim",
    branch = "0.10",
    event = "BufReadPost",
    config = function()
      vim.opt.numberwidth = 8
      local builtin = require("statuscol.builtin")
      require("statuscol").setup({
        setopt = true,
        ft_ignore = { "lazy", "harpoon" },
        bt_ignore = { "nofile", "prompt", "quickfix", "help" },
        segments = {
          { sign = { namespace = { "diagnostic*", "Marks*" }, auto = false, maxwidth = 1, colwidth = 1 } },
          { text = { " ", builtin.lnumfunc, " " } },
          { sign = { namespace = { "gitsigns" }, auto = false, maxwidth = 1, colwidth = 1 } },
          { text = { " " } },
        },
      })
    end,
  },
}
