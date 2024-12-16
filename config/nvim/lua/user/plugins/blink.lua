local M = {
  'saghen/blink.cmp',
  version = 'v0.*',
  dependencies = 'rafamadriz/friendly-snippets',
  event = "InsertEnter",
  opts = {
    keymap = { preset = 'default' },
    appearance = {
      use_nvim_cmp_as_default = true,
      nerd_font_variant = 'mono'
    },
    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },
    completion = {
      trigger = {
        show_on_insert_on_trigger_character = false,
      },
      menu = {
        border = "rounded",
        winhighlight = "Normal:CmpPmenu,CursorLine:PmenuSel,Search:None",
      },
    },
    -- signature = { enabled = true } -- experimental feature
  },
  opts_extend = { "sources.default" }
}

return M
