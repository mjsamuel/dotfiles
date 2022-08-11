local keymap = vim.keymap
local g = vim.g

g.mapleader = " "
keymap.set("n", ";", ":")

keymap.set("n", "<Leader>p", "p`[v`]=")

-- Allow gf to open non-existent files
keymap.set("", "gf", ":edit <cfile><CR>")

-- quickly edit/reload vim config
keymap.set("n", "<Leader>ve", ":edit ~/.config/nvim/init.lua<cr>")
keymap.set("n", "<Leader>vr", ":source ~/.config/nvim/init.lua<cr>")

-- telescope
keymap.set("n", "<Leader>f", "<cmd>Telescope find_files<cr>")
keymap.set("n", "<Leader>r", "<cmd>Telescope live_grep<cr>")
keymap.set("n", "<Leader>b", "<cmd>Telescope buffers<cr>")
keymap.set("n", "<Leader>h", "<cmd>Telescope help_tags<cr>")

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

-- nvim tree
keymap.set('n', '<leader>n', ':NvimTreeFindFileToggle<cr>', { silent = true, noremap = true })

-- trouble
keymap.set('n', "<leader>t", ":TroubleToggle document_diagnostics<cr>")
keymap.set('n', "<leader>T", ":TroubleToggle workspace_diagnostics<cr>")

-- debug
keymap.set("n", "<leader>dc", ":lua require(\"dap\").continue()<cr>")
keymap.set("n", "<leader>db", ":lua require(\"dap\").toggle_breakpoint()<cr>")
