local keymap = vim.keymap

keymap.set("n", ";", ":")
keymap.set("v", ";", ":")

-- Allow gf to open non-existent files
keymap.set("", "gf", ":edit <cfile><CR>")

-- telescope
keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<cr>")
keymap.set("n", "<Leader>fg", "<cmd>Telescope live_grep<cr>")
keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>fh", "<cmd>Telescope help_tags<cr>")

-- buffer management
keymap.set("n", "<Leader>bb", "<cmd>Telescope buffers<cr>")

-- git
keymap.set("n", "<Leader>gg", "<cmd>Telescope git_status<cr>")
keymap.set("n", "<Leader>gc", "<cmd>Telescope git_commits<cr>")
keymap.set("n", "<Leader>gs", "<cmd>Telescope git_stash<cr>")
keymap.set("n", "<Leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>")
keymap.set("n", "<Leader>gB", "<cmd>Git blame<cr>")

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
keymap.set("n", "<Leader>af", ":lua vim.lsp.buf.code_action()<cr>")
keymap.set("n", "<Leader>rf", ":lua vim.lsp.buf.rename()<cr>")
keymap.set(
	"v",
	"<leader>rr",
	"<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
	{ noremap = true }
)

-- format
keymap.set("n", "<Leader>p", ":Format<cr>")

-- neo-tree
keymap.set("n", "<leader>n", ":Neotree reveal toggle position=right<cr>", { silent = true, noremap = true })

-- trouble
keymap.set("n", "<leader>t", ":TroubleToggle document_diagnostics<cr>")
keymap.set("n", "<leader>T", ":TroubleToggle workspace_diagnostics<cr>")

-- debug
keymap.set("n", "<leader>du", ':lua require("dapui").toggle()<cr>')
keymap.set("n", "<leader>dc", ':lua require("dap").continue()<cr>')
keymap.set("n", "<leader>db", ':lua require("dap").toggle_breakpoint()<cr>')

-- theme
keymap.set("n", "<leader>s", ":lua ToggleTheme()<cr>")

-- yank
keymap.set("n", "Y", "<cmd>Telescope registers<cr>")
