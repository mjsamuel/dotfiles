local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    "L3MON4D3/LuaSnip",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-path",
    "rafamadriz/friendly-snippets",
    "onsails/lspkind.nvim",
  },
}

function M.config()
  local cmp = require("cmp")
  local lspkind = require("lspkind")
  local luasnip = require("luasnip")
  require("luasnip.loaders.from_vscode").lazy_load()
  luasnip.config.setup({})

  local window_opts = {
    border = "rounded",
    winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
  }

  cmp.setup({
    preselect = cmp.PreselectMode.None,
    snippet = {
      expand = function(args) luasnip.lsp_expand(args.body) end,
    },
    completion = { completeopt = "menu,menuone,noinsert" },
    window = {
      completion = window_opts,
      documentation = window_opts,
    },
    formatting = {
      format = lspkind.cmp_format({ before = function(_, vim_item) return vim_item end }),
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-l>"] = cmp.mapping(function()
        if luasnip.expand_or_locally_jumpable() then luasnip.expand_or_jump() end
      end, { "i", "s" }),
      ["<C-h>"] = cmp.mapping(function()
        if luasnip.locally_jumpable(-1) then luasnip.jump(-1) end
      end, { "i", "s" }),
    }),
    sources = {
      { name = "nvim_lsp" },
      { name = "luasnip" },
      { name = "path" },
    },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = "path" } }),
  })
end

return M
