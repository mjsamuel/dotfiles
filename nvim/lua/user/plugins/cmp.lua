local M = {
	"hrsh7th/nvim-cmp",
	event = "InsertEnter",
	dependencies = {
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "hrsh7th/cmp-cmdline" },
		{ "onsails/lspkind.nvim" },
		{ "L3MON4D3/LuaSnip" },
		{ "rafamadriz/friendly-snippets" },
	},
}

function M.config()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	local lspkind = require("lspkind")

	require("luasnip.loaders.from_vscode").lazy_load()

	-- Set completeopt to have a better completion experience
	vim.o.completeopt = "menuone,longest,preview"

	cmp.setup({
		experimental = {
			ghost_text = true,
		},
		window = {
			completion = {
				border = require("user.misc.opts").border,
				winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
			},
			documentation = {
				border = require("user.misc.opts").border,
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
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		mapping = cmp.mapping.preset.insert({
			["<C-b>"] = cmp.mapping.scroll_docs(-4),
			["<C-f>"] = cmp.mapping.scroll_docs(4),
			["<C-Space>"] = cmp.mapping.complete(),
			["<C-e>"] = cmp.mapping.abort(),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_next_item()
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				else
					fallback()
				end
			end, { "i", "s" }),
			["<S-Tab>"] = cmp.mapping(function(fallback)
				if cmp.visible() then
					cmp.select_prev_item()
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, { "i", "s" }),
		}),
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "buffer" },
			{ name = "luasnip" },
		}),
	})
end

return M
