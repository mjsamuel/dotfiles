local silicon = {}

function silicon.screenshot()
  local Job = require("plenary.job")

  local esc = vim.api.nvim_replace_termcodes("<esc>", true, false, true)
  vim.api.nvim_feedkeys(esc, "x", false)
  local start_line = vim.fn.getpos("'<")[2]
  local end_line = vim.fn.getpos("'>")[2]
  local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
  local textCode = table.concat(lines, "\n")

  local filetype = vim.bo.filetype
  local output_path = string.format(
    "%s/Desktop/%s.%s-%s.%s.png",
    os.getenv("HOME"),
    vim.fn.expand("%:p:h:t"),
    start_line,
    end_line,
    filetype
  )

  local args = {
    "--language",
    filetype,
    "--window-title",
    "../" .. vim.fn.expand("%:t"),
    "--line-offset",
    start_line,
    -- "--background",
    -- "#fff0",
    -- "--theme",
    -- "gruvbox-dark",
    "--output",
    output_path,
  }

  local job = Job:new({
    command = "silicon",
    args = args,
    on_exit = function(_, code)
      if code == 0 then
        print("Screenshot saved to " .. output_path)
      end
    end,
    on_stderr = function(_, data, _)
      print(vim.inspect(data))
    end,
    writer = textCode,
    cwd = vim.fn.getcwd(),
  })
  job:sync()
end

return silicon
