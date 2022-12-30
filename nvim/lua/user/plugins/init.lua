return {
	{ "nvim-lua/plenary.nvim" },
	{
		"nvim-telescope/telescope-fzf-native.nvim",
		build = "make",
	},
	{ "hrsh7th/cmp-nvim-lsp" },
	{ "hrsh7th/cmp-buffer" },
	{ "hrsh7th/cmp-path" },
	{ "hrsh7th/cmp-cmdline" },
	{ "onsails/lspkind.nvim" },
	{ "L3MON4D3/LuaSnip" },
	{
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{ "tpope/vim-fugitive" },
	{ "kyazdani42/nvim-web-devicons" },
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{ "nvim-neo-tree/neo-tree.nvim" },
	{
		"windwp/nvim-autopairs",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	{ "gpanders/editorconfig.nvim" },
	{
		"numToStr/Comment.nvim",
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/trouble.nvim",
		config = function()
			require("trouble")
		end,
	},
	{ "rcarriga/nvim-dap-ui" },
	{ "nathom/filetype.nvim" },
	{
		"Shatur/neovim-session-manager",
		config = function()
			require("session_manager").setup({
				autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
			})
		end,
	},
	{ "nvim-treesitter/nvim-treesitter-context" },
	{ "MunifTanjim/nui.nvim" },
}
