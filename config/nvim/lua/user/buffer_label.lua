return function(buffer)
  local path = vim.api.nvim_buf_get_name(buffer)
  local name = vim.fn.fnamemodify(path, ":t")
  local icon = ""

  if name ~= "" then
    icon = require("nvim-web-devicons").get_icon(name, vim.fn.fnamemodify(path, ":e"), { default = true })
  else
    name = vim.bo[buffer].filetype ~= "" and vim.bo[buffer].filetype or "No Name"
  end

  return icon, name
end
