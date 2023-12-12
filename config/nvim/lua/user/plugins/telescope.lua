local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
  },
}

local telescopeDefaultTheme = {
  theme = "ivy",
  prompt_title = false,
  results_title = false,
  preview_title = false,
  layout_config = { preview_width = 0.55 },
}

local function open_with_trouble(prompt_bufnr, _mode)
  return require("trouble.providers.telescope").open_with_trouble(prompt_bufnr, _mode)
end

function M.config()
  require("telescope").setup({
    defaults = {
      vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
      },
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      file_ignore_patterns = { ".git/", "node_modules" },
      path_display = { "truncate" },
      winblend = 0,
      color_devicons = true,
      mappings = {
        -- TODO: trouble is loaded when telescope is, figure out how to lazy load trouble when needed
        i = {
          ["<c-q>"] = open_with_trouble,
          ["<Tab>"] = require("telescope.actions.layout").toggle_preview,
        },
        n = { ["<c-q>"] = open_with_trouble },
      },
      preview = {
        hide_on_startup = true,
      },
    },
    pickers = {
      buffers = vim.tbl_extend("force", telescopeDefaultTheme, {
        show_all_buffers = true,
        ignore_current_buffer = true,
        sort_lastused = true,
        mappings = {
          i = { [";"] = "delete_buffer" },
        },
      }),
      diagnostics = telescopeDefaultTheme,
      find_files = vim.tbl_extend("force", telescopeDefaultTheme, { hidden = true }),
      git_commits = telescopeDefaultTheme,
      git_stash = telescopeDefaultTheme,
      git_status = telescopeDefaultTheme,
      help_tags = telescopeDefaultTheme,
      live_grep = telescopeDefaultTheme,
      lsp_implementations = vim.tbl_extend("force", telescopeDefaultTheme, { show_line = false }),
      lsp_references = vim.tbl_extend("force", telescopeDefaultTheme, { show_line = false }),
      registers = telescopeDefaultTheme,
      grep_string = telescopeDefaultTheme,
      lsp_document_symbols = telescopeDefaultTheme,
      lsp_workspace_symbols = telescopeDefaultTheme,
      git_bcommits = telescopeDefaultTheme,
    },
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = "smart_case",
      },
      ["ui-select"] = {
        require("telescope.themes").get_cursor(),
      },
    },
  })

  local extension = { "fzf", "ui-select" }
  for _, e in ipairs(extension) do
    require("telescope").load_extension(e)
  end
end

return M
