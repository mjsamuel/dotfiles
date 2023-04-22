vim.keymap.set("i", "=", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }

  if left_of_cursor_range[2] < 0 then
    return "="
  end

  local node = vim.treesitter.get_node({ pos = left_of_cursor_range })
  local nodes_active_in = {
    "attribute_name",
  }
  if not node or not vim.tbl_contains(nodes_active_in, node:type()) then
    return "="
  end

  return '=""<left>'
end, { expr = true, buffer = true })
