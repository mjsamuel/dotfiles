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
  local lines = vim.api.nvim_buf_get_text(0, start_pos[1] - 1, start_pos[2], end_pos[1] - 1, end_pos[2] + 1, {})
  return {
    text = table.concat(lines, "\n"),
    pos = start_pos,
    end_pos = end_pos
  }
end

---Run a git command in the current working directory.
---@return string[]? output lines, or nil if the command failed
M.git = function(...)
  local out = vim.fn.systemlist({ "git", ... })
  return vim.v.shell_error == 0 and out or nil
end

---Find the ref the current branch most likely forked from.
---Picks the nearest ref behind HEAD, so stacked branches resolve to their
---parent rather than main. --no-contains drops the current branch and anything
---stacked on it.
---@return string?
M.find_fork_point = function()
  local refs = M.git("for-each-ref", "--no-contains=HEAD", "--format=%(refname:short)",
    "refs/heads", "refs/remotes/origin/HEAD")
  local nearest = vim.iter(refs or {})
      :map(function(ref) return { ref = ref, distance = tonumber(M.git("rev-list", "--count", ref .. "..HEAD")[1]) } end)
      :fold(nil, function(best, c) return (not best or c.distance < best.distance) and c or best end)
  return nearest and nearest.ref
end

return M
