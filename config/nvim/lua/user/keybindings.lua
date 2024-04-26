local keymap = vim.keymap

keymap.set("n", " ", "<nop>") -- leader is space so disabling default behaviour

-- search
keymap.set("n", "s.", "<cmd>Telescope resume<cr>") -- [s]earch repeat
keymap.set("n", "sb", "<cmd>Telescope buffers<cr>") -- [s]earch [b]uffers
keymap.set("n", "sd", "<cmd>Telescope diagnostics<cr>") -- [s]earch [d]iagnostics
keymap.set("n", "sh", "<cmd>Telescope help_tags<cr>") -- [s]earch [h]elp
keymap.set("n", "sr", "<cmd>Telescope live_grep<cr>") -- [s]earch using [r]ipgrep
keymap.set("n", "ss", "<cmd>Telescope find_files<cr>")
keymap.set("v", "sr", '"zy:Telescope live_grep default_text=<C-r>z<cr>') -- [s]earch using [r]ipgrep with visual selection

-- git
keymap.set("n", "[g", function() require("gitsigns").prev_hunk() end, { silent = true })
keymap.set("n", "]g", function() require("gitsigns").next_hunk() end, { silent = true })
keymap.set("v", "gr", function() require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
keymap.set("v", "gs", function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end)
keymap.set("n", "<C-g>", function() require("gitsigns").blame_line({ ignore_whitespace = true, full = true }) end)
vim.api.nvim_create_user_command("Diff", function()
  require("gitsigns").diffthis(nil, { split = "botright" })
  vim.cmd("wincmd w")
end, { nargs = 0 })

-- lsp
keymap.set("n", "D", function() vim.diagnostic.open_float() end)
keymap.set("n", "K", function() vim.lsp.buf.hover() end)
keymap.set("n", "[d", vim.diagnostic.goto_prev, { silent = true })
keymap.set("n", "]d", vim.diagnostic.goto_next, { silent = true })
keymap.set("n", "gD", function() vim.lsp.buf.declaration() end)
keymap.set("n", "gd", function() vim.lsp.buf.definition() end)
keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>")
keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>")
keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end)
keymap.set({ "n", "v" }, "<Leader>f", function() vim.lsp.buf.format() end)

-- code refactoring/fixing
keymap.set({ "n", "v" }, "<Leader>ra", function() vim.lsp.buf.code_action() end)
keymap.set("n", "<Leader>rr", function() vim.lsp.buf.rename() end)

-- move selected code when in visual mode
keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- keep cursor in middle when jumping through files
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- harpooon
keymap.set("n", "M", function() require("harpoon.ui").toggle_quick_menu() end)
keymap.set("n", "mm", function() require("harpoon.mark").add_file() end)
for i, key in ipairs({ "w", "f", "p", "r", "s", "t", "x", "c", "v" }) do
  keymap.set("n", "m" .. key, function() require("harpoon.ui").nav_file(i) end)
  keymap.set("n", "m" .. i, function() require("harpoon.ui").nav_file(i) end)
end

-- yank
keymap.set("n", "<leader>y", '<cmd>let @+=@" | echo "Copied to system clipboard"<cr>', { silent = true })

-- make
local function make(make_args)
  if not vim.g.makefile_exists then return end
  vim.cmd("wa | silent make " .. (make_args or ""))
  if #vim.fn.getqflist() > 0 then
    vim.cmd("copen")
  else
    vim.cmd("cclose")
  end
end
keymap.set("n", "gm", function() make() end, { silent = true })

-- copilot
local right_key = vim.api.nvim_replace_termcodes("<Right>", true, false, true)
keymap.set("i", "<Right>", function()
  local cp = require("copilot.suggestion")
  if cp.is_visible() then
    cp.accept()
  else
    vim.api.nvim_feedkeys(right_key, "n", false)
  end
end)
