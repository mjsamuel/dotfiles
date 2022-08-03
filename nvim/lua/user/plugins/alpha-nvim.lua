local alpha = require("alpha")

local function button(sc, txt, keybind)
  local sc_ = sc:gsub("%s", ""):gsub("SPC", "<leader>")

  local opts = {
    position = "center",
    text = txt,
    shortcut = sc,
    cursor = 5,
    width = 36,
    align_shortcut = "right",
    hl = "AlphaButtons",
  }

  if keybind then
    opts.keymap = { "n", sc_, keybind, { noremap = true, silent = true } }
  end

  return {
    type = "button",
    val = txt,
    on_press = function()
      local key = vim.api.nvim_replace_termcodes(sc_, true, false, true)
      vim.api.nvim_feedkeys(key, "normal", false)
    end,
    opts = opts,
  }
end

local options = {

  header = {
    type = "text",
    val = {
        "         ⢀⣀⣤⡤⠶⠶⣶⡶⢤⣤⣄⡀         ",
        "      ⣀⡴⠞⠋⠁⠈⠙⢳⡄ ⠙⢷⡌⠻⣝⢷⣦⣄      ",
        "    ⣠⡾⣻⠏  ⢀⣠⣤⠾⠃   ⢻⡄⠙⣎⢷⣹⡷⣄    ",
        "   ⣴⢋⡼⠋⣀⡴⠞⠋⢁⣀⣀⣀⣀⣀⣀⣸⠇ ⢹⡈⣧⢿⢻⣧⡀  ",
        "  ⣼⣣⡞⣡⡾⣋⡴⠖⣛⣉⣉⣉⣀⡀     ⣸⠃⣿⢸⣿⡏⣷  ",
        " ⢰⣿⠏⣴⢫⡾⣩⡴⠛⣉⣡⣤⣀⠉⠙⠳⣦⣀⣀⣴⠏⢠⡏⣼⢹⣇⣿⡇ ",
        " ⢸⡟⣼⢣⡟⣴⢋⡴⠛⠉  ⠈⠻⣄  ⠉⠉⠁⣠⡟⣰⠏⡾⣼⢣⣷ ",
        " ⢸⣷⡏⣾⣸⢇⡾⢁⣴⠖⠲⢦⣄⡀⠘⠳⢦⣤⠴⠞⢋⣴⢋⡾⣿⠋⣼⡟ ",
        " ⠘⣿⣧⡇⣿⢸⠁⣾⠁   ⠈⠙⠳⠦⢤⣤⠴⠞⣋⣴⣿⠞⢁⡾⣻⠇ ",
        "  ⠹⣇⣇⣿⢸ ⡇ ⢠⡶⠒⠲⠶⠦⠤⠤⠶⠶⢛⣭⠞⠁⣠⠞⣡⡏  ",
        "   ⠙⣿⣻⡼⣇⢿ ⢸⡅     ⣀⣤⠞⠋ ⢀⡼⠋⣴⠏   ",
        "    ⠈⠻⣿⡹⣎⢷⡈⢷⡀  ⣴⠛⠉   ⢠⣟⣥⠞⠁    ",
        "       ⠙⠻⢷⣽⣦⡙⢦⣀⠈⠳⢦⣀⣠⡤⠞⠋⠁      ",
        "           ⠉⠉⠛⠛⠛⠛⠉⠉⠁          "
    },
    opts = {
      position = "center",
      hl = "AlphaHeader",
    },
  },

  buttons = {
    type = "group",
    val = {
      button("r", "  Recent files", ":Telescope oldfiles<CR>"),
      button("s", "  Open last session", ":SessionManager load_last_session<CR>"),
      button('e', '  New file' , ':ene<CR>'),
      button("c", "  Configuration", ":e $MYVIMRC | :cd %:p:h <CR>"),
      button("q", "  Quit NVIM", ":q<CR>"),
    },
    opts = {
      spacing = 0,
    },
  },
}

-- dynamic header padding
local fn = vim.fn
local marginTopPercent = 0.2
local headerPadding = fn.max { 2, fn.floor(fn.winheight(0) * marginTopPercent) }

alpha.setup {
  layout = {
    { type = "padding", val = headerPadding },
    options.header,
    { type = "padding", val = 2 },
    options.buttons,
  },
  opts = {},
}
