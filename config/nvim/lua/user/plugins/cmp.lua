local M = {
  "hrsh7th/nvim-cmp",
  event = "InsertEnter",
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path" },
    { "onsails/lspkind.nvim" },
    { "L3MON4D3/LuaSnip" },
  },
}

function M.config()
  local cmp = require("cmp")
  local lspkind = require("lspkind")

  -- Set completeopt to have a better completion experience
  vim.o.completeopt = "menuone,longest,preview"

  cmp.setup({
    experimental = {
      ghost_text = true,
    },
    window = {
      completion = {
        border = "rounded",
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
      documentation = {
        border = "rounded",
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
    },
    formatting = {
      format = lspkind.cmp_format({
        before = function(_, vim_item)
          return vim_item
        end,
      }),
    },

    mapping = cmp.mapping.preset.insert({
      ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<S-CR>"] = cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Replace,
        select = true,
      }),
    }),
    sources = cmp.config.sources({
      { name = "nvim_lsp" },
    }),
  })


  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({ { name = "path" } }),
  })
end

return M
