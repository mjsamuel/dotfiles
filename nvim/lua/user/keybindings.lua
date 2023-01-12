local keymap = vim.keymap

keymap.set("n", ";", ":")
keymap.set("v", ";", ":")

-- Allow gf to open non-existent files
keymap.set("", "gf", ":edit <cfile><CR>")

-- search
keymap.set("n", "<Leader>sb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>sf", "<cmd>Telescope find_files<cr>")
keymap.set("n", "<Leader>sh", "<cmd>Telescope help_tags<cr>")
keymap.set("n", "<Leader>ss", "<cmd>Telescope live_grep<cr>")

-- window management
keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })
keymap.set("n", "<Leader>ww", "<C-W>p")
keymap.set("n", "<Leader>wh", "<C-W>s")
keymap.set("n", "<Leader>wv", "<C-W>v")
keymap.set("n", "<Leader>wd", "<C-W>c")

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

-- debug
keymap.set("n", "<leader>du", ':lua require("dapui").toggle()<cr>')
keymap.set("n", "<leader>dc", ':lua require("dap").continue()<cr>')
keymap.set("n", "<leader>db", ':lua require("dap").toggle_breakpoint()<cr>')

-- yank
keymap.set("n", "Y", "<cmd>Telescope registers<cr>")

-- misc
keymap.set("n", "<Leader>f", "<cmd>Format<cr>")
keymap.set("n", "<Leader>h", "<cmd>Telescope help_tags<cr>")
keymap.set("n", "<Leader>l", "<cmd>Lazy<cr>c")
keymap.set("n", "<leader>T", "<cmd>TroubleToggle workspace_diagnostics<cr>")
keymap.set(
	"n",
	"<leader>n",
	"<cmd>Neotree reveal toggle position=right<cr>",
	{ silent = true, noremap = true }
)
keymap.set("n", "<leader>s", "<cmd>lua ToggleTheme()<cr>")
keymap.set("n", "<leader>t", "<cmd>TroubleToggle document_diagnostics<cr>")
