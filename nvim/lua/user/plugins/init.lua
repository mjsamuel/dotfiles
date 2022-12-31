return {
	"nvim-lua/plenary.nvim",
	"MunifTanjim/nui.nvim",
	"kyazdani42/nvim-web-devicons",
	{ "gpanders/editorconfig.nvim", event = "BufReadPre" },
	{
		"kylechui/nvim-surround",
		keys = {
			{ "ys", desc = "Surround" },
			{ "S", mode = "v", desc = "Surround" },
		},
		config = true,
	},
	{ "tpope/vim-fugitive", cmd = "Git" },
	{
		"lewis6991/gitsigns.nvim",
		event = "BufReadPre",
		config = true,
	},
	{ "nvim-neo-tree/neo-tree.nvim", cmd = "Neotree" },
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},
	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gc", desc = "Comment" },
		},
		config = true,
	},
	{
		"folke/trouble.nvim",
		cmd = "TroubleToggle",
		config = true,
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
	{
		"monaqa/dial.nvim",
		keys = { "<C-a>", { "<C-x>", mode = "n" } },
	},
	{
		"RRethy/vim-illuminate",
		event = "BufReadPost",
		config = function()
			require("illuminate").configure({ delay = 200 })
		end,
	},
}
