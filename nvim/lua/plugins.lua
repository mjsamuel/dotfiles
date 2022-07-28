return require('packer').startup(function(use)
    use { "wbthomason/packer.nvim" }
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                -- A list of parser names, or "all"
                ensure_install = { 'lua', 'typescript', 'java', 'json', 'markdown', 'make', 'python'},

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,
                -- Automatically install missing parsers when entering buffer
                auto_install = true,

                highlight = {
                    -- `false` will disable the whole extension
                    enable = true,
                },
                indent = {
                    enable = true
                }
            }
        end
    }

    use {
        'nvim-lua/plenary.nvim',
        config = function()
            print('vim surround loaded ')
        end
    }

    use 'tpope/vim-surround'

    use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }

    use {
        'nvim-telescope/telescope.nvim',
        requires = { {'nvim-lua/plenary.nvim'} },
        config = function()
            require('telescope').setup {
                defaults = {},
                pickers = {
                    find_files = {
                        theme = "dropdown",
                    }
                },
            }
            require('telescope').load_extension('fzf')
        end
    }

    use 'kyazdani42/nvim-web-devicons'

    use {
        'Shatur/neovim-ayu',
        config = require('ayu').colorscheme()
    }

    use {
        'nvim-lualine/lualine.nvim',
        config = require('lualine').setup({
            options = {
                theme = 'ayu',
            },
        })
    }

    use 'neovim/nvim-lspconfig'

    use 'williamboman/nvim-lsp-installer'

    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'
end)

