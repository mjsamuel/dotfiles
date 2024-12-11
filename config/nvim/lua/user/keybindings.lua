local keymap = vim.keymap

keymap.set({ "n", "v" }, " ", "<nop>") -- leader is space so disabling default behaviour

-- search
keymap.set("n", "s.", function() require("telescope.builtin").resume() end)      -- [s]earch repeat
keymap.set("n", "sb", function() require("telescope.builtin").buffers() end)     -- [s]earch [b]uffers
keymap.set("n", "sd", function() require("telescope.builtin").diagnostics() end) -- [s]earch [d]iagnostics
keymap.set("n", "sh", function() require("telescope.builtin").help_tags() end)   -- [s]earch [h]elp
keymap.set("n", "sr", function()                                                 -- [s]earch using [r]ipgrep
  require('telescope').extensions.live_grep_args.live_grep_args()
end)
keymap.set("n", "ss", function() require("telescope.builtin").find_files() end)
keymap.set("v", "sr", function() -- [s]earch using [r]ipgrep with visual selection
  require("telescope-live-grep-args.shortcuts").grep_visual_selection()
end)

-- git
keymap.set("n", "[g", function() require("gitsigns").nav_hunk('prev') end, { silent = true })
keymap.set("n", "]g", function() require("gitsigns").nav_hunk('next') end, { silent = true })
keymap.set("v", "gr", function() require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end) -- [g]it [r]eset
keymap.set("v", "gs", function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end) -- [g]it [s]tage
keymap.set("n", "<C-g>", function() require("gitsigns").blame_line({ ignore_whitespace = true, full = true }) end)
vim.api.nvim_create_user_command("Blame", function() require("gitsigns").blame() end, { nargs = 0 })
vim.api.nvim_create_user_command("Diff", function()
  require("gitsigns").diffthis(nil, { split = "botright" })
  vim.cmd("wincmd w")
end, { nargs = 0 })

-- lsp
keymap.set("n", "D", function() vim.diagnostic.open_float() end)           -- [D]iagnostics
keymap.set("n", "gd", function() vim.lsp.buf.definition() end)             -- [g]o to [d]efinition
keymap.set("n", "gt", function() vim.lsp.buf.type_definition() end)        -- [g]o to [t]ype definition
keymap.set({ "n", "v" }, "<Leader>f", function() vim.lsp.buf.format() end) -- [f]ormat
-- overriding default behaviour with telescope picker
keymap.set("n", "gri", function() require("telescope.builtin").lsp_implementations() end)
keymap.set("n", "grr", function() require("telescope.builtin").lsp_references() end)
keymap.set({ "n", "v" }, "gra", function() -- [a]ction
  -- in case telescope has not lazily loaded
  require("telescope")
  vim.lsp.buf.code_action()
end)

-- move selected code when in visual mode
keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- keep cursor in middle when jumping through files
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- harpooon (supercharged [m]arks)
keymap.set("n", "M", function() require("harpoon.ui").toggle_quick_menu() end) -- [M]arks
keymap.set("n", "mm", function() require("harpoon.mark").add_file() end)       -- [m]ake [m]ark
for i, key in ipairs({ "w", "f", "p", "r", "s", "t", "x", "c", "v" }) do       -- coresponds to numpad on my keyboard layout
  keymap.set("n", "m" .. key, function() require("harpoon.ui").nav_file(i) end)
  keymap.set("n", "m" .. i, function() require("harpoon.ui").nav_file(i) end)
end

-- make
local function make(make_args)
  if not vim.g.makefile_exists then return end
  vim.cmd("wa | silent make " .. (make_args or ""))
  if #vim.fn.getqflist() == 0 then
    vim.cmd("cclose")
    return
  end
  vim.cmd("copen")
end
keymap.set("n", "gm", function() make() end, { silent = true })

-- copilot
keymap.set("i", "<Right>", function()
  local cp = require("copilot.suggestion")
  local right_key = vim.api.nvim_replace_termcodes("<Right>", true, false, true)
  if not cp.is_visible() then
    vim.api.nvim_feedkeys(right_key, "n", false)
    return
  end
  cp.accept()
end)
vim.api.nvim_create_user_command("Chat", ":CopilotChat<cr>", { nargs = 0, range = true })

-- guard against typos
vim.api.nvim_create_user_command("W", function() vim.cmd(":w") end, { nargs = 0 })
vim.api.nvim_create_user_command("Wa", function() vim.cmd(":wa") end, { nargs = 0 })
vim.api.nvim_create_user_command("WA", function() vim.cmd(":wa") end, { nargs = 0 })
vim.api.nvim_create_user_command("Wqa", function() vim.cmd(":wqa") end, { nargs = 0 })

-- misc
keymap.set("n", "\\", function() require("oil").open() end, { silent = true })
keymap.set("n", "<leader>y", '<cmd>let @+=@" | echo "Copied to system clipboard"<cr>', { silent = true })
