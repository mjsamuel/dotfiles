local M = {
  "goolord/alpha-nvim",
  lazy = false,
}

function M.config()
  local alpha = require("alpha")
  local dashboard = require("alpha.themes.dashboard")
  local path = require("plenary.path")
  local nvim_web_devicons = require("nvim-web-devicons")

  local options = {
    disallowed_file_types = { "gitcommit" },
    recent_files = {
      number_of_items = 5,
      special_shortcuts = { "a", "r", "s", "t", "d" },
    },
    padding = 2,
    header_art = {
      "███    ██ ██    ██ ██ ███    ███",
      "████   ██ ██    ██ ██ ████  ████",
      "██ ██  ██ ██    ██ ██ ██ ████ ██",
      "██  ██ ██  ██  ██  ██ ██  ██  ██",
      "██   ████   ████   ██ ██      ██",
    },
  }

  local function get_greeting(name)
    local hour = os.date("*t").hour
    local greeting = ""
    if hour == 23 or hour < 7 then
      greeting = "  Sleep well"
    elseif hour < 12 then
      greeting = "  Good morning"
    elseif hour >= 12 and hour < 18 then
      greeting = "  Good afternoon"
    elseif hour >= 18 and hour < 21 then
      greeting = "  Good evening"
    elseif hour >= 21 then
      greeting = "望 Good night"
    end
    return greeting .. ", " .. name
  end

  local function get_extension(filename)
    local match = filename:match("^.+(%..+)$")
    local extension = ""
    if match ~= nil then
      extension = match:sub(2)
    end
    return extension
  end

  local function get_icon(filename)
    local extension = get_extension(filename)
    return nvim_web_devicons.get_icon(filename, extension, { default = true })
  end

  local function file_button(filename, shortcut, short_function)
    short_function = short_function or filename
    local icon_text
    local button_highlight = {}

    local icon, highlight = get_icon(filename)
    local hl_option_type = type(nvim_web_devicons.highlight)
    if hl_option_type == "boolean" then
      if highlight and nvim_web_devicons.highlight then
        table.insert(button_highlight, { highlight, 0, 1 })
      end
    end
    if hl_option_type == "string" then
      table.insert(button_highlight, { nvim_web_devicons.highlight, 0, 1 })
    end
    icon_text = icon .. "  "

    local button_element = dashboard.button(shortcut, icon_text .. short_function, "<cmd>e " .. filename .. " <cr>")
    local function_start = short_function:match(".*/")
    if function_start ~= nil then
      table.insert(button_highlight, { "Comment", #icon_text, #function_start + #icon_text })
    end
    button_element.opts.hl = button_highlight
    return button_element
  end

  local function get_recent_files_buttons(number_of_items, shortcut_keys)
    number_of_items = number_of_items or 9

    local current_working_directory = vim.fn.getcwd()
    local recent_files = {}
    for _, file in pairs(vim.v.oldfiles) do
      if #recent_files == number_of_items then
        break
      end

      local in_current_working_directory = vim.startswith(file, current_working_directory)
      local readable = vim.fn.filereadable(file) == 1
      local disallowed_type = vim.tbl_contains(options.disallowed_file_types, get_extension(file))

      if readable and in_current_working_directory and not disallowed_type then
        table.insert(recent_files, file)
      end
    end

    local target_width = 35

    local items = {}
    for i, filename in ipairs(recent_files) do
      local filename_short
      filename_short = vim.fn.fnamemodify(filename, ":.")

      if #filename_short > target_width then
        filename_short = path.new(filename_short):shorten(1, { -2, -1 })
        if #filename_short > target_width then
          filename_short = path.new(filename_short):shorten(1, { -1 })
        end
      end

      local shortcut = ""
      if i <= #shortcut_keys then
        shortcut = shortcut_keys[i]
      else
        shortcut = tostring(i - 1 - #shortcut_keys)
      end

      local file_button_element = file_button(filename, " " .. shortcut, filename_short)
      table.insert(items, file_button_element)
    end
    return {
      type = "group",
      val = items,
      opts = {},
    }
  end

  local sections = {}
  sections.header = {
    type = "text",
    val = options.header_art,
    opts = { position = "center" },
  }

  sections.greeting = {
    type = "text",
    val = get_greeting("Matthew"),
    opts = {
      position = "center",
      hl = "String",
    },
  }

  sections.stats = {
    type = "text",
    val = function()
      local stats = require("lazy").stats()
      return string.format(
        "%s/%s plugins ﮣ loaded in %.3f seconds",
        stats.loaded,
        stats.count,
        (stats.startuptime / 1000)
      )
    end,
    opts = {
      position = "center",
      hl = "Comment",
    },
  }

  sections.recent_files = {
    type = "group",
    val = {
      {
        type = "text",
        val = "Recent files",
        opts = {
          shrink_margin = false,
          position = "center",
        },
      },
      { type = "padding", val = 1 },
      {
        type = "group",
        val = function()
          return {
            get_recent_files_buttons(options.recent_files.number_of_items, options.recent_files.special_shortcuts),
          }
        end,
        opts = { shrink_margin = false },
      },
    },
  }

  sections.buttons = {
    type = "group",
    val = {
      { type = "text", val = "Quick links", opts = { position = "center" } },
      { type = "padding", val = 1 },
      dashboard.button("S", "  Open last session", ":SessionManager load_current_dir_session<CR>"),
      dashboard.button("n", "  New file", ":ene <BAR> startinsert <CR>"),
      dashboard.button("c", "  Configuration", ":e $MYVIMRC | :cd %:p:h <CR>"),
      dashboard.button("u", "  Update plugins", ":Lazy update<CR>"),
      dashboard.button("q", "  Quit", ":qa<CR>"),
    },
    position = "center",
  }

  local total_height = 27 -- TODO: dynamically calculate this
  local padding_top = function()
    return math.floor((vim.o.lines - total_height) / 2)
  end

  local opts = {
    layout = {
      { type = "padding", val = padding_top },
      sections.header,
      { type = "padding", val = options.padding },
      sections.greeting,
      sections.stats,
      { type = "padding", val = options.padding },
      sections.recent_files,
      { type = "padding", val = options.padding },
      sections.buttons,
    },
  }

  alpha.setup(opts)
end

return M
