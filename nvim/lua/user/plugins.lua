local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
  vim.cmd [[packadd packer.nvim]]
end

require('packer').startup(function(use)
    use {
        'lewis6991/impatient.nvim',
        config = function()
            require('user.plugins.impatient')
        end
    }

    use { 'wbthomason/packer.nvim' }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require('user.plugins.treesitter')
        end
    }

    use {
        'nvim-telescope/telescope.nvim',
        requires = { { 'nvim-lua/plenary.nvim' } },
        config = function()
            require('user.plugins.telescope')
        end
    }

    use { 'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    use {
        'neovim/nvim-lspconfig',
        config = function()
            require('user.plugins.lspconfig')
        end
    }

    use {
        'williamboman/nvim-lsp-installer',
        config = function()
            require('user.plugins.lsp-installer')
        end
    }

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            'hrsh7th/cmp-nvim-lsp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-cmdline'
        },
        config = function()
           require('user.plugins.cmp')
        end
    }

    use { 'tpope/vim-surround' }

    use { 'tpope/vim-commentary' }

    use { 'tpope/vim-fugitive', opt = true, cmd = 'Git' }

    use { 'kyazdani42/nvim-web-devicons' }

    use {
        'Shatur/neovim-ayu',
        config = function()
            require('user.plugins.theme')
        end
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = {
            'Shatur/neovim-ayu',
            'kyazdani42/nvim-web-devicons'
        },
        config = function()
            require('user.plugins.lualine')
        end
    }

    use {
        'lewis6991/gitsigns.nvim',
        config = function()
            require('user.plugins.gitsigns')
        end
    }

    use {
        'kyazdani42/nvim-tree.lua',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function()
            require('user.plugins.nvim-tree')
        end
    }

    use {
        'L3MON4D3/LuaSnip',
        config = function()
            require('user.plugins.luasnip')
        end
    }

    use {
        'windwp/nvim-autopairs',
        config = function()
            require('nvim-autopairs').setup()
        end
    }

    use {
        'goolord/alpha-nvim',
        config = function()
            require('user.plugins.alpha-nvim')
        end
    }

    if packer_bootstrap then
        require('packer').sync()
    end
end)

