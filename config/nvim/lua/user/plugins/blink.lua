vim.pack.add({
  { src= "https://github.com/saghen/blink.cmp", version = "v1.9.1" },
  "https://github.com/rafamadriz/friendly-snippets"
})

require('blink.cmp').setup({
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
})
