local fn = vim.fn

local packer_bootstrap
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	packer_bootstrap =
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
	vim.cmd([[packadd packer.nvim]])
end

require("packer").startup(function(use)
	use({
		"lewis6991/impatient.nvim",
		config = function()
			require("impatient")
		end,
	})

	use({ "wbthomason/packer.nvim" })

	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("user.plugins.treesitter")
		end,
	})

	use({
		"nvim-telescope/telescope.nvim",
		requires = { "nvim-lua/plenary.nvim" },
		cmd = "Telescope",
		config = function()
			require("user.plugins.telescope")
		end,
	})

	use({
		"nvim-telescope/telescope-fzf-native.nvim",
		run = "make",
	})

	use({
		"neovim/nvim-lspconfig",
		config = function()
			require("user.plugins.lspconfig")
		end,
	})

	use({
		"williamboman/mason.nvim",
		requires = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
		config = function()
			require("user.plugins.mason")
		end,
	})

	use({
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		requires = {
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-buffer",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-cmdline",
			"onsails/lspkind.nvim",
		},
		config = function()
			require("user.plugins.cmp")
		end,
	})

	use({
		"kylechui/nvim-surround",
		config = function()
			require("nvim-surround").setup({})
		end,
	})

	use({
		"tpope/vim-fugitive",
		cmd = "Git",
	})

	use({
		"kyazdani42/nvim-web-devicons",
		module = "nvim-web-devicons",
	})

	use({
		"nvim-lualine/lualine.nvim",
		requires = { "kyazdani42/nvim-web-devicons" },
		after = "gruvbox-material",
		config = function()
			require("user.plugins.lualine")
		end,
	})

	use({
		"sainnhe/gruvbox-material",
		config = function()
			require("user.plugins.theme")
		end,
	})

	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup()
		end,
	})

	use({
		"kyazdani42/nvim-tree.lua",
		requires = "kyazdani42/nvim-web-devicons",
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		config = function()
			require("user.plugins.nvim-tree")
		end,
	})

	use({
		"L3MON4D3/LuaSnip",
		wants = "friendly-snippets",
		after = "nvim-cmp",
		config = function()
			require("luasnip")
		end,
	})

	use({
		"windwp/nvim-autopairs",
		after = "nvim-cmp",
		config = function()
			require("nvim-autopairs").setup()
		end,
	})

	use({
		"lukas-reineke/indent-blankline.nvim",
		config = function()
			require("user.plugins.indent-blankline")
		end,
	})

	use({ "gpanders/editorconfig.nvim" })

	use({
		"mhartington/formatter.nvim",
		config = function()
			require("user.plugins.formatter")
		end,
	})

	use({
		"numToStr/Comment.nvim",
		module = "Comment",
		keys = { "gc", "gb" },
		config = function()
			require("Comment").setup()
		end,
	})

	use({
		"folke/trouble.nvim",
		requires = "kyazdani42/nvim-web-devicons",
		cmd = { "Trouble", "TroubleToggle" },
		config = function()
			require("trouble")
		end,
	})

	use({
		"mfussenegger/nvim-dap",
		config = function()
			require("user.plugins.dap")
		end,
	})

	use({
		"rcarriga/nvim-dap-ui",
		module = "dapui",
		config = function()
			require("user.plugins.dap-ui")
		end,
	})

	use({
		"mfussenegger/nvim-jdtls",
		ft = "java",
		config = function()
			require("user.plugins.jdtls")
		end,
	})

	use({
		"nvim-treesitter/nvim-treesitter-context",
		cmd = { "NvimTreeToggle", "NvimTreeFocus" },
		config = function()
			require("user.plugins.context")
		end,
	})

	use("rafamadriz/friendly-snippets")

	use("nathom/filetype.nvim")

	use({
		"goolord/alpha-nvim",
		config = function()
			require("user.plugins.alpha")
		end,
	})

	use({
		"Shatur/neovim-session-manager",
		config = function()
			require("session_manager").setup({
				autoload_mode = require("session_manager.config").AutoloadMode.Disabled,
			})
		end,
	})

	if packer_bootstrap then
		require("packer").sync()
	end
end)
