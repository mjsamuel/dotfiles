local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    { "nvim-telescope/telescope-ui-select.nvim" },
  },
}

TelescopeDefaultTheme = {
  theme = "ivy",
  prompt_title = false,
  results_title = false,
  preview_title = false,
  layout_config = { preview_width = 0.55 },
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
      mappings = {
        -- TODO: trouble is loaded when telescope is, figure out how to lazy load trouble when needed
        i = { ["<c-q>"] = require("trouble.providers.telescope").open_with_trouble },
        n = { ["<c-q>"] = require("trouble.providers.telescope").open_with_trouble },
      },
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
      lsp_implementations = vim.tbl_extend("force", TelescopeDefaultTheme, { show_line = false }),
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
