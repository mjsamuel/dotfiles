local actions = require 'telescope.actions'


require('telescope').setup {
    defaults = {
        sorting_strategy = 'ascending',
        layout_config = {
            prompt_position = 'top',
        },
        mappings = {
            i = {
                ['<esc>'] = actions.close,
            }
        },
        file_ignore_patterns = { '.git/' },
    },
    pickers = {
        find_files = {
            hidden = true
        },
        buffers = {
            ignore_current_buffer = true,
            sort_lastused = true,
        }
    },
    extension = {
        fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
        }
    }
}

require('telescope').load_extension('fzf')
