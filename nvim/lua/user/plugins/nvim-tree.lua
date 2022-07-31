require('nvim-tree').setup {
    git = {
        ignore = false,
    }
}

vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeFindFileToggle<CR>', { silent = true, noremap = true })
