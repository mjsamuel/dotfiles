local M = {
  "nvim-telescope/telescope.nvim",
  cmd = "Telescope",
  dependencies = {
    "nvim-telescope/telescope-ui-select.nvim",
    "MunifTanjim/nui.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  },
}

local create_minimal_layout, telescopeDefaultTheme
function M.config()
  local telescope = require("telescope")
  telescope.setup({
    defaults = {
      -- functional
      vimgrep_arguments = { "rg", "--color=never", "--no-heading", "--with-filename", "--line-number", "--column", "--smart-case", },
      sorting_strategy = "ascending",
      file_ignore_patterns = { ".git/", "node_modules" },
      mappings = {
        i = { ["<Tab>"] = require("telescope.actions.layout").toggle_preview, },
      },
      -- apperance
      preview = { hide_on_startup = true },
      path_display = { "truncate" },
      color_devicons = true,
      winblend = 0,
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
        require("telescope.themes").get_cursor({ prompt_title = false }),
      },
    },
  })

  local extension = { "fzf", "ui-select" }
  for _, e in ipairs(extension) do
    telescope.load_extension(e)
  end
end

telescopeDefaultTheme = {
  create_layout = function(picker)
    return create_minimal_layout(picker)
  end,
  prompt_title = false,
  results_title = false,
  preview_title = false,
  layout_config = {
    size = { width = "90%", height = "60%" },
    preview = 60,
  },
}


create_minimal_layout = function(picker)
  local TSLayout = require("telescope.pickers.layout")
  local Layout = require("nui.layout")
  local Popup = require("nui.popup")

  local function make_popup(options)
    local popup = Popup(options)
    function popup.border:change_title(title) popup.border.set_text(popup.border, "top", title) end

    return TSLayout.Window(popup)
  end

  local components = {}

  ---@format disable-next
  components.prompt = make_popup({
    enter = true,
    border = {
      style = {
        top_left =    "╭",    top = "─",    top_right = "┬",
        left =        "│",                      right = "│",
        bottom_left = "├", bottom = "─", bottom_right = "┤",
      },
      text = { top = picker.prompt_title, top_align = "center" },
    },
    win_options = { winhighlight = "Normal:Normal" },
  })

  ---@format disable-next
  components.results = make_popup({
    focusable = false,
    border = {
      style = {
            top_left = "",     top = "",     top_right = "",
               left = "│",                      right = "│",
        bottom_left = "╰", bottom = "─", bottom_right = "┴",
      },
      text = { top = picker.results_title, top_align = "center" },
    },
    win_options = { winhighlight = "Normal:Normal" },
  })

  ---@format disable-next
  components.preview = make_popup({
    focusable = false,
    border = {
      style = {
           top_left = "",    top = "─",    top_right = "╮",
               left = "",                      right = "│",
        bottom_left = "", bottom = "─", bottom_right = "╯",
      },
      text = { top = picker.preview_title, top_align = "center" },
    },
  })

  local function get_box()
    local preview_hidden = picker.hidden_previewer
    local results_size = picker.hidden_previewer and "100%" or
        (100 - picker.layout_config.preview) .. "%"
    return Layout.Box({
      Layout.Box(
        { Layout.Box(components.prompt, { size = 3 }), Layout.Box(components.results, { grow = 1 }) },
        { dir = "col", size = results_size }
      ),
      not preview_hidden and Layout.Box(components.preview, { grow = 1 }) or nil,
    }, { dir = "row" })
  end

  local function prepare_layout_parts(layout)
    layout.results = components.results
    layout.prompt = components.prompt

    if picker.hidden_previewer then
      layout.preview = nil
      components.prompt.border:set_style({ top_right = "╮" })
      components.results.border:set_style({ bottom_right = "╯" })
    else
      layout.preview = components.preview
      components.prompt.border:set_style({ top_right = "┬" })
      components.results.border:set_style({ bottom_right = "┴" })
    end
  end

  -- initial setup of layout
  local layout = Layout({
    relative = "editor",
    position = "50%",
    size = picker.layout_config.size,
  }, get_box())
  layout.picker = picker
  prepare_layout_parts(layout)

  -- how the layout will update
  local layout_update = layout.update
  function layout:update()
    prepare_layout_parts(layout)
    layout_update(self, { size = picker.layout_config.size }, get_box())
  end

  return TSLayout(layout)
end

return M
