return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"kyazdani42/nvim-web-devicons",
	{ "gpanders/editorconfig.nvim", lazy = false },
	{
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "Surround" },
			{ "S", mode = "v", desc = "Surround" },
		},
		config = function()
			require("nvim-surround").setup({})
		end,
	},
	{ "tpope/vim-fugitive", cmd = "Git" },
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		config = function()
			require("gitsigns").setup()
		end,
	},
	{ "nvim-neo-tree/neo-tree.nvim", cmd = "Neotree",
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = function()
			require("nvim-autopairs").setup()
		end,
	},
	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gc", desc = "Comment" },
		},
		config = function()
			require("Comment").setup()
		end,
	},
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
		config = function()
			require("trouble")
		end,
	},
	{
		"Shatur/neovim-session-manager",
		lazy = false,
		config = function()
			require("session_manager").setup({
				autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
			})
		end,
	},
}
