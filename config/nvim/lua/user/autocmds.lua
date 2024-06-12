-- Check if we need to reload the file when it changed
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, { command = "checktime" })

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  callback = function() vim.cmd("tabdo wincmd =") end,
})

-- go to last locaction when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
  callback = function() vim.highlight.on_yank({ higroup = "Visual", timeout = "200", on_visual = false }) end,
})

-- enable spell check for specific filetypes
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
    vim.opt_local.textwidth = 80
  end,
})

-- project settings
vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
  callback = function()
    -- makefile exists
    vim.g.makefile_exists = vim.fn.findfile("Makefile") ~= ""
    -- error format
    if vim.fn.findfile("source/pdxinfo") ~= "" then -- playdate project
      vim.opt.errorformat = "%trror:\\ %f:%l:%m,%-G%.%#"
    end
  end,
})
