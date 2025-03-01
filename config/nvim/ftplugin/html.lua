vim.opt_local.conceallevel = 2

vim.keymap.set("i", "=", function()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local left_of_cursor_range = { cursor[1] - 1, cursor[2] - 1 }

  if left_of_cursor_range[2] < 0 then
    return "="
  end

  local node = vim.treesitter.get_node({ pos = left_of_cursor_range, ignore_injections = false })
  local nodes_active_in = { "attribute_name" }
  vim.print(node and node:type())
  if not node or not vim.tbl_contains(nodes_active_in, node:type()) then
    return "="
  end

  return '=""<left>'
end, { expr = true, buffer = true })
