local M = {
  "nvim-telescope/telescope.nvim",
  commit = "762fcbf360dfc789e2dd435bda353a73242c2504",
  cmd = "Telescope",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
  },
}

TelescopeDefaultTheme = {
  theme = "minimal",
  layout_strategy = "horizontal",
  layout_config = {
    horizontal = { width = 0.9, height = 0.65, preview_width = 0.55, prompt_position = "top" },
  },
  prompt_title = false,
  results_title = false,
  preview_title = false,
}

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
      theme = TelescopeDefaultTheme,
    },
    pickers = {
      buffers = vim.tbl_extend("force", TelescopeDefaultTheme, {
        show_all_buffers = true,
        ignore_current_buffer = true,
        sort_lastused = true,
        mappings = {
          i = { [";"] = "delete_buffer" },
        },
      }),
      diagnostics = TelescopeDefaultTheme,
      find_files = vim.tbl_extend("force", TelescopeDefaultTheme, { hidden = true }),
      git_commits = TelescopeDefaultTheme,
      git_stash = TelescopeDefaultTheme,
      git_status = TelescopeDefaultTheme,
      help_tags = TelescopeDefaultTheme,
      live_grep = TelescopeDefaultTheme,
      lsp_implementations = TelescopeDefaultTheme,
      lsp_references = vim.tbl_extend("force", TelescopeDefaultTheme, { show_line = false }),
      registers = TelescopeDefaultTheme,
      grep_string = TelescopeDefaultTheme,
      lsp_document_symbols = TelescopeDefaultTheme,
      lsp_workspace_symbols = TelescopeDefaultTheme,
      git_bcommits = TelescopeDefaultTheme,
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
      file_browser = vim.tbl_extend("force", TelescopeDefaultTheme, {
        cwd = vim.fn.expand("%:p:h"),
        git_status = false,
        hidden = true,
        select_buffer = true,
        previewer = false,
      }),
    },
  })

  local extension = { "fzf", "ui-select", "file_browser" }
  for _, e in ipairs(extension) do
    require("telescope").load_extension(e)
  end
end

return M
