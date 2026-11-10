local M = {}

local function source_segments(buf, row, text, lang)
  local parser = vim.treesitter.get_parser(buf, lang)
  parser:parse({ row, row + 1 })
  local styles = {}
  parser:for_each_tree(function(tree, language)
    local query = vim.treesitter.query.get(language:lang(), "highlights")
    if not query then return end
    for id, node, metadata in query:iter_captures(tree:root(), buf, row, row + 1) do
      local capture = query.captures[id]
      if capture and capture:sub(1, 1) ~= "_" and capture ~= "spell" and capture ~= "nospell" then
        local range = vim.treesitter.get_range(node, buf, metadata[id])
        local start_row, start_col, end_row, end_col = range[1], range[2], range[4], range[5]
        if start_row <= row and end_row >= row then
          local first = start_row < row and 0 or start_col
          local last = end_row > row and #text or end_col
          local priority = tonumber(metadata.priority or (metadata[id] and metadata[id].priority)) or 100
          local style = { hl = "@" .. capture .. "." .. language:lang(), priority = priority }
          for col = first + 1, math.min(last, #text) do
            if not styles[col] or priority >= styles[col].priority then styles[col] = style end
          end
        end
      end
    end
  end)
  local segments = {}
  local first, highlight = 1, styles[1] and styles[1].hl or "TroubleText"
  for col = 2, #text + 1 do
    local next_highlight = styles[col] and styles[col].hl or "TroubleText"
    if col > #text or next_highlight ~= highlight then
      segments[#segments + 1] = { text = text:sub(first, col - 1), hl = highlight }
      first, highlight = col, next_highlight
    end
  end
  return segments
end

function M.format(item)
  local text = item.item.text or ""
  local header, snippet = text:match("^(%a+%s+%([^)]*%): )(.*)$")
  local kind = text:match("^(%a+)")
  if not header or (kind ~= "Added" and kind ~= "Changed" and kind ~= "Removed") then
    return { { text = text, hl = "TroubleText" } }
  end
  local segments = { { text = header, hl = "TroubleText" } }
  local plain = { text = snippet, hl = "TroubleText" }
  local buf = item.buf or vim.fn.bufnr(item.filename)
  -- Deleted snippets refer to the old revision, not the current buffer's line.
  if kind == "Removed" or buf <= 0 or not vim.api.nvim_buf_is_loaded(buf) then
    segments[#segments + 1] = plain
    return segments
  end
  local row = item.pos[1] - 1
  local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
  if line ~= snippet then
    segments[#segments + 1] = plain
    return segments
  end
  local ft = vim.bo[buf].filetype
  if ft == "" then ft = vim.filetype.match({ filename = item.filename, buf = buf }) end
  local lang = ft and vim.treesitter.language.get_lang(ft)
  local ok, source = pcall(source_segments, buf, row, snippet, lang)
  if ok then vim.list_extend(segments, source)
  else segments[#segments + 1] = plain end
  return segments
end

return M
