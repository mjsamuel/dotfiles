-- insert a comma after the current line if it doesn't already have one
vim.keymap.set("n", "o", function()
  local line = vim.api.nvim_get_current_line()
  local should_add_comma = string.find(line, "[^,{[]$")
  return should_add_comma and "A,<cr>" or "o"
end, { buffer = true, expr = true })
