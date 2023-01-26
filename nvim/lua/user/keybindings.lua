local keymap = vim.keymap

keymap.set("n", " ", "<nop>")

keymap.set("n", ";", ":")
keymap.set("v", ";", ":")

-- Allow gf to open non-existent files
keymap.set("", "gf", ":edit <cfile><CR>")

-- turn of vim recording
keymap.set("n", "q", "<nop>")

-- search
keymap.set("n", "<Leader>sb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>sh", "<cmd>Telescope help_tags<cr>")
keymap.set("n", "<Leader>sr", "<cmd>Telescope live_grep<cr>")
keymap.set("n", "<Leader>ss", "<cmd>Telescope find_files<cr>")

-- window management
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
keymap.set("n", "<Leader>ww", "<C-W>w")
keymap.set("n", "<Leader>wh", "<C-W>s")
keymap.set("n", "<Leader>wv", "<C-W>v")
keymap.set("n", "<Leader>wx", "<C-W>c")

-- buffer management
keymap.set("n", "<Leader>b", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
keymap.set("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })

-- git
keymap.set("n", "<Leader>gg", "<cmd>Telescope git_status<cr>")
keymap.set("n", "<Leader>gc", "<cmd>Telescope git_commits<cr>")
keymap.set("n", "<Leader>gs", "<cmd>Telescope git_stash<cr>")
keymap.set("n", "<Leader>gb", "<cmd>Git blame<cr>")

-- lsp
keymap.set("n", "gd", "<cmd>lua vim.lsp.buf.definition()<cr>")
keymap.set("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<cr>")
keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<cr>")
keymap.set("n", "gw", "<cmd>lua vim.lsp.buf.document_symbol()<cr>")
keymap.set("n", "gw", "<cmd>lua vim.lsp.buf.workspace_symbol()<cr>")
keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>")
keymap.set("n", "gt", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
keymap.set("n", "K", "<cmd>lua vim.lsp.buf.hover()<cr>")

-- code refactoring/fixing
keymap.set("n", "<Leader>ca", ":lua vim.lsp.buf.code_action()<cr>")
keymap.set("n", "<Leader>cc", ":lua vim.lsp.buf.rename()<cr>")
keymap.set("n", "<Leader>cf", "<cmd>Format<cr>")
keymap.set(
  "v",
  "<leader>cr",
  "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
  { noremap = true }
)
keymap.set("n", "<leader>cs", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]]) -- replace current word under cursor using sed
keymap.set("n", "<leader>cp", ":lua require('copilot.suggestion').toggle_auto_trigger()<cr>") -- toggle copilot

-- move selected code when in visual mode
keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv")
keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv")

-- keep cursor in middle when jumping through files
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- debug
keymap.set("n", "<leader>du", ':lua require("dapui").toggle()<cr>')
keymap.set("n", "<leader>dc", ':lua require("dap").continue()<cr>')
keymap.set("n", "<leader>db", ':lua require("dap").toggle_breakpoint()<cr>')

-- yank
keymap.set("n", "Y", "<cmd>Telescope registers<cr>")
keymap.set("n", "<leader>y", ':let @+=@"<cr>', { silent = true }) -- copy what's in current register to system clipboard

-- misc
keymap.set("n", "<Leader>f", "<cmd>Format<cr>")
keymap.set("v", "<Leader>f", "<cmd>Format<cr>")
keymap.set("n", "<Leader>h", "<cmd>Telescope help_tags<cr>")
keymap.set("n", "<Leader>l", "<cmd>Lazy<cr>c")
keymap.set("n", "<leader>T", "<cmd>TroubleToggle workspace_diagnostics<cr>")
keymap.set("n", "<leader>n", "<cmd>Neotree reveal toggle<cr>", { silent = true, noremap = true })
keymap.set("n", "<leader>t", "<cmd>TroubleToggle document_diagnostics<cr>")
keymap.set("v", "<leader>s", function()
  require("user.misc.silicon").screenshot()
end)
