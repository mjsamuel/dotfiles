local keymap = vim.keymap
local g = vim.g

g.mapleader = " "
keymap.set("n", ";", ":")

-- Allow gf to open non-existent files
keymap.set("", "gf", ":edit <cfile><CR>")

-- telescope
keymap.set("n", "<Leader>ff", "<cmd>Telescope find_files<cr>")
keymap.set("n", "<Leader>fg", "<cmd>Telescope live_grep<cr>")
keymap.set("n", "<Leader>fb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>fh", "<cmd>Telescope help_tags<cr>")

-- buffer management
keymap.set("n", "<Leader>bb", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>bd", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>bn", ":bn<cr>")
keymap.set("n", "<Leader>bp", ":bp<cr>")

-- git
keymap.set("n", "<Leader>gg", "<cmd>Telescope git_status<cr>")
keymap.set("n", "<Leader>gc", "<cmd>Telescope git_commits<cr>")
keymap.set("n", "<Leader>gs", "<cmd>Telescope git_stash<cr>")
keymap.set("n", "<Leader>gb", "<cmd>:Git blame<cr>")

-- lsp
keymap.set("n", "gd", ":lua vim.lsp.buf.definition()<cr>")
keymap.set("n", "gD", ":lua vim.lsp.buf.declaration()<cr>")
keymap.set("n", "gi", ":lua vim.lsp.buf.implementation()<cr>")
keymap.set("n", "gw", ":lua vim.lsp.buf.document_symbol()<cr>")
keymap.set("n", "gw", ":lua vim.lsp.buf.workspace_symbol()<cr>")
keymap.set("n", "gr", ":lua vim.lsp.buf.references()<cr>")
keymap.set("n", "gt", ":lua vim.lsp.buf.type_definition()<cr>")
keymap.set("n", "K", ":lua vim.lsp.buf.hover()<cr>")

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
