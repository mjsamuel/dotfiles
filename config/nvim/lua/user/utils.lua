local M = {}

---Copy the given text to the system clipboard and print a confirmation message.
M.copy_to_system_clipboard = function(text)
  vim.fn.setreg("+", text)
  local formatted_text = string.match(text, "^%s*(.-)%s*$")
  local max_length = 12
  if (#formatted_text > max_length) then
    formatted_text = formatted_text:sub(1, max_length) .. "..."
  end
  print("Copied '" .. formatted_text .. "' to system clipboard")
end

---Get the currently visually selected text - shamelessly stolen from folke's
---snacks.nvim. Side effect: exits visual mode
---@return {text: string, pos: integer[], end_pos: integer[]}?
M.get_visual_selection = function()
  -- exit if not in visual mode
  local visual_modes = { "v", "V" }
  local current_mode = vim.fn.mode():sub(1, 1)
  if not vim.tbl_contains(visual_modes, current_mode) then
    return
  end

  -- exit visual mode
  vim.cmd("normal! " .. current_mode)

  local start_pos = vim.api.nvim_buf_get_mark(0, "<")
  local end_pos = vim.api.nvim_buf_get_mark(0, ">")
  local lines = vim.api.nvim_buf_get_text(0, start_pos[1] - 1, start_pos[2], end_pos[1] - 1, end_pos[2], {})
  return {
    text = table.concat(lines, "\n"),
    pos = start_pos,
    end_pos = end_pos
  }
end

return M
