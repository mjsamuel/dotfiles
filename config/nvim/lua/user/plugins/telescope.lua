local M = {
  "nvim-telescope/telescope.nvim",
  commit = "762fcbf360dfc789e2dd435bda353a73242c2504",
  cmd = "Telescope",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
  },
}

function M.config()
  local minimal_opts = {
    theme = "minimal",
    layout_strategy = "horizontal",
    layout_config = {
      horizontal = { width = 0.9, height = 0.65, preview_width = 0.6, prompt_position = "top" },
    },
    prompt_title = false,
    results_title = false,
    preview_title = false,
  }

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
      theme = minimal_opts,
    },
    pickers = {
      buffers = vim.tbl_extend("force", minimal_opts, {
        show_all_buffers = true,
        ignore_current_buffer = true,
        sort_lastused = true,
        mappings = {
          i = { [";"] = "delete_buffer" },
        },
      }),
      diagnostics = minimal_opts,
      find_files = vim.tbl_extend("force", minimal_opts, { hidden = true }),
      git_commits = minimal_opts,
      git_stash = minimal_opts,
      git_status = minimal_opts,
      help_tags = minimal_opts,
      live_grep = minimal_opts,
      lsp_implementations = minimal_opts,
      lsp_references = vim.tbl_extend("force", minimal_opts, { show_line = false }),
      registers = minimal_opts,
      grep_string = minimal_opts,
      lsp_document_symbols = minimal_opts,
      lsp_workspace_symbols = minimal_opts,
      git_bcommits = minimal_opts,
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
      file_browser = minimal_opts,
    },
  })

  local extension = { "fzf", "ui-select", "file_browser" }
  for _, e in ipairs(extension) do
    require("telescope").load_extension(e)
  end
end

return M
