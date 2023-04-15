function ToggleTheme()
  if vim.o.background == "dark" then
    vim.o.background = "light"
  else
    vim.o.background = "dark"
  end
end

local function get_os_appearance()
  if vim.fn.has("mac") ~= 1 then
    return "dark"
  end
  vim.fn.system("defaults read -g AppleInterfaceStyle")
  return vim.v.shell_error == 1 and "light" or "dark"
end

return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "night",
        light_style = "day",
      })
      vim.cmd("colorscheme tokyonight")
      vim.o.background = get_os_appearance()
    end,
  },
  {
    -- @credit https://github.com/jrnxf/dot/blob/872603b349cc4934a15b90634f9fc52918445fb0/config/nvim/lua/plugins/colorscheme.lua
    "EdenEast/nightfox.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      local terafox = require("nightfox.palette").load("terafox")

      local colors = {
        added_line = "#0e3929",
        added_text = "#19674a",
        deleted_line = "#2d1c1c",
        deleted_text = "#4e3131",
        off_white_text = "#cccccc",
      }

      local groups = {
        CmpPmenuBorder = { link = "NormalFloatBorder" },
        CursorLine = { bg = terafox.bg1 },
        DiagnosticSignInfo = { link = "FloatBorder" }, -- used heavily by noice
        DiffAdd = { bg = colors.added_line }, -- show added lines
        DiffAddAsDelete = { bg = colors.deleted_line }, -- used in diffview (left panel) highlight line that changed
        DiffAddText = { bg = colors.added_text, fg = colors.off_white_text }, -- show added characters within added lines
        DiffChange = { bg = colors.deleted_line }, -- fugitive (left side) to show what LINE text was changed on
        DiffDelete = { bg = colors.deleted_line, fg = colors.deleted_text }, -- shows fully deleted blocks of code
        DiffDeleteText = { bg = colors.deleted_text, fg = colors.off_white_text }, -- diffview (left panel) highlight word that changed
        DiffText = { bg = colors.deleted_text, fg = colors.off_white_text }, -- fugitive (left side) to show exact characters that deleted
        FloatBorder = { fg = terafox.bg3 },
        LeapBackdrop = { link = "Comment" },
        LeapMatch = { bg = terafox.magenta.dim, fg = colors.off_white_text },
        LeapLabelPrimary = { bg = terafox.sel0, fg = colors.off_white_text },
        LeapLabelSecondary = { bg = terafox.sel1, fg = colors.off_white_text },
        LspInfoBorder = { link = "FloatBorder" },
        MasonHeader = { bg = terafox.green.dim },
        MasonHeaderSecondary = { bg = terafox.green.dim },
        MasonHighlightBlock = { bg = terafox.green.dim },
        MasonHighlightBlockBold = { bg = terafox.green.dim },
        Normal = { bg = terafox.bg0 },
        NormalFloat = { bg = terafox.bg0 },
        NormalFloatBorder = { link = "FloatBorder" },
        NormalNC = { bg = terafox.bg0 },
        Pmenu = { bg = terafox.bg1 },
        PmenuBorder = { link = "FloatBorder" },
        StatusLine = { bg = "#152528" }, -- this must be style different that NC otherwise vim will use ^^^^^^ to differentiate
        StatusLineNC = { bg = "#152528", fg = "#7aa4a1" }, -- status line none current
        Substitute = { bg = terafox.magenta.dim, fg = "white" },
        TelescopeBorder = { link = "FloatBorder" },
        TelescopeMatching = { fg = terafox.cyan.bright },
        VertSplit = { fg = terafox.bg2 },
        MatchParen = { bg = terafox.blue.dim, fg = colors.off_white_text },
      }

      require("nightfox").setup({
        options = {
          styles = {
            comments = "italic",
            keywords = "bold",
            types = "italic,bold",
          },
        },
        groups = {
          terafox = groups,
        },
      })
    end,
  },
}
