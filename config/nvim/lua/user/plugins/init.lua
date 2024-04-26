return {
  "nvim-lua/plenary.nvim",
  { "tpope/vim-sleuth", event = "VeryLazy" },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = { diff_opts = { vertical = false } },
  },
  { "ThePrimeagen/harpoon", opts = { mark_branch = true } },
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
  -- Appearance related plugins
  "kyazdani42/nvim-web-devicons",
  { "j-hui/fidget.nvim", event = "LspAttach", opts = {} },
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
          { sign = { namespace = { "diagnostic*" }, auto = false, maxwidth = 1, colwidth = 1 } },
          {
            text = { " ", builtin.lnumfunc, " " },
            condition = { true, builtin.not_empty },
          },
          { sign = { namespace = { "gitsigns" }, auto = false, maxwidth = 1, colwidth = 1 } },
          { text = { " " } },
        },
      })
    end,
  },
}
