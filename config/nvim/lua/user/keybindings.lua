local keymap = vim.keymap

keymap.set("n", " ", "<nop>")

keymap.set({ "n", "v" }, ";", ":")
keymap.set({ "n", "v" }, ",", ";")

-- turn off vim recording
keymap.set("n", "q", "<nop>")

-- search
keymap.set("n", "<Leader>s.", "<cmd>Telescope resume<cr>")
keymap.set("n", "<Leader>sb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>sd", "<cmd>Telescope diagnostics<cr>")
keymap.set("n", "<Leader>sh", "<cmd>Telescope help_tags<cr>")
keymap.set("n", "<Leader>sr", "<cmd>Telescope live_grep<cr>") -- ripgrep
keymap.set("n", "<Leader>ss", "<cmd>Telescope find_files<cr>")
keymap.set("n", "<Leader>sw", "<cmd>Telescope grep_string<cr>") -- grep word under cursor

-- window management
keymap.set("n", "<Leader>ww", "<C-W>w")
keymap.set("n", "<Leader>wh", "<C-W>s")
keymap.set("n", "<Leader>wv", "<C-W>v")

-- buffer management
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
keymap.set("n", "<Leader>b", "<cmd>Telescope buffers<cr>")

-- git
keymap.set("n", "<Leader>gh", "<cmd>Telescope git_bcommits<cr>")
keymap.set("n", "<Leader>gg", "<cmd>Telescope git_status<cr>")
keymap.set("n", "<Leader>gb", "<cmd>Git blame<cr>")

-- lsp
keymap.set("n", "D", "<cmd>lua vim.diagnostic.open_float()<cr>")
keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")
keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>")
keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>")
keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
keymap.set("n", "gw", "<cmd>lua vim.lsp.buf.document_symbol()<cr>")
keymap.set("n", "gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>")
keymap.set({ "n", "v" }, "<Leader>f", "<cmd>lua vim.lsp.buf.format()<cr>")

-- code refactoring/fixing
keymap.set("n", "<Leader>ra", ":lua vim.lsp.buf.code_action()<cr>")
keymap.set(
  "v",
  "<Leader>ra",
  ":lua require('refactoring').select_refactor()<CR>",
  { noremap = true, silent = true, expr = false }
)
keymap.set("n", "<Leader>rr", ":lua vim.lsp.buf.rename()<cr>")

-- move selected code when in visual mode
keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- keep cursor in middle when jumping through files
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- debug
keymap.set("n", "<leader>du", ':lua require("dapui").toggle()<cr>', { silent = true })
keymap.set("n", "<leader>dc", ':lua require("dap").continue()<cr>', { silent = true })
keymap.set("n", "<leader>dd", ':lua require("dap").toggle_breakpoint()<cr>', { silent = true })

-- harpooon
keymap.set("n", "M", "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>")
keymap.set("n", "mm", "<cmd>lua require('harpoon.mark').add_file()<CR>")
for i, key in ipairs({ "q", "w", "f", "p", "g" }) do
  keymap.set("n", "m" .. key, "<cmd>lua require('harpoon.ui').nav_file(" .. i .. ") <CR>")
  keymap.set("n", "m" .. i, "<cmd>lua require('harpoon.ui').nav_file(" .. i .. ") <CR>")
end

-- yank
keymap.set("n", "Y", "<cmd>Telescope registers<cr>")
keymap.set("n", "<leader>y", '<cmd>let @+=@" | echo "Copied to system clipboard"<cr>', { silent = true })

-- make
local function make(make_args)
  vim.cmd("w | silent make " .. (make_args or ""))
  local qflist = vim.fn.getqflist()
  if #qflist > 0 then
    for _, v in ipairs(qflist) do
      v.lnum = v.lnum + vim.g.qf_line_offset
    end
    vim.fn.setqflist(qflist)
    require("trouble").open("quickfix")
  else
    require("trouble").close()
  end
end
keymap.set("n", "gmm", function()
  make()
end, { silent = true })
keymap.set("n", "gmr", function()
  make("run")
end, { silent = true })

-- copilot
keymap.set("i", "<Right>", function()
  local cp = require("copilot.suggestion")
  if cp.is_visible() then
    cp.accept()
  else
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Right>", true, false, true), "n", false)
  end
end)

-- misc
keymap.set("n", "<leader>/", ':lua require("oil").open()<cr>', { silent = true })
