vim.opt_local.conceallevel = 2

vim.keymap.set("i", "=", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }

  if left_of_cursor_range[2] < 0 then
    return "="
  end

  return '=""<left>'
end, { expr = true, buffer = true })
