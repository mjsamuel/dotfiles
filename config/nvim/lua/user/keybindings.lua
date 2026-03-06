local keymap = vim.keymap
local command = { set = vim.api.nvim_create_user_command }

keymap.set({ "n", "v" }, " ", "<nop>") -- leader is space so disabling default behaviour

-- search
keymap.set("n", "s.", function() require("snacks").picker.resume() end)                 -- [s]earch repeat
keymap.set("n", "sb", function() require("snacks").picker.buffers() end)                -- [s]earch [b]uffers
keymap.set("n", "sd", function() require("snacks").picker.diagnostics() end)            -- [s]earch [d]iagnostics
keymap.set("n", "sgg", function() require("snacks").picker.git_status() end)            -- [s]earch [g]it status
keymap.set("n", "sgb", function() require("snacks").picker.git_branches() end)          -- [s]earch [g]it [b]ranches
keymap.set("n", "sgl", function() require("snacks").picker.git_log_line() end)          -- [s]earch [g]it [b]ranches
keymap.set("n", "sh", function() require("snacks").picker.help() end)                   -- [s]earch [h]elp
keymap.set("n", "sr", function() require("snacks").picker.grep() end)                   -- [s]earch using [r]ipgrep
keymap.set("n", "ss", function() require("snacks").picker.files({ hidden = true }) end) -- [s]earch files
keymap.set("v", "sr", function() require("snacks").picker.grep_word() end)              -- [s]earch using [r]ipgrep with visual selection
keymap.set("v", "ss", function()
  local visual = require("snacks").picker.util.visual()
  if visual then
    require("snacks").picker.files({ search = visual.text:gsub("\n", " ") })
  end
end) -- [s]earch files with visual selection

-- git
keymap.set("n", "[g", function() require("gitsigns").nav_hunk('prev') end, { silent = true })
keymap.set("n", "]g", function() require("gitsigns").nav_hunk('next') end, { silent = true })
keymap.set("v", "gr", function() require("gitsigns").reset_hunk({ vim.fn.line("."), vim.fn.line("v") }) end) -- [g]it [r]eset
keymap.set("v", "gs", function() require("gitsigns").stage_hunk({ vim.fn.line("."), vim.fn.line("v") }) end) -- [g]it [s]tage
keymap.set("n", "<C-g>", function() require("gitsigns").blame_line({ ignore_whitespace = true, full = true }) end)
command.set("Blame", function() require("gitsigns").blame() end, { nargs = 0 })
command.set("Diff", function()
  require("gitsigns").diffthis(nil, { split = "botright" })
  vim.cmd("wincmd w")
end, { nargs = 0 })
command.set("Github", function(args)
  local opts = {}
  if args.range > 0 then
    opts = {
      line_start = args.line1,
      line_end = args.line2,
    }
  end
  require("snacks").gitbrowse.open(opts)
end, { nargs = 0, range = true })

-- lsp
keymap.set({ "n", "v" }, "<Leader>f", function() require("conform").format() end) -- [f]ormat
keymap.set("n", "D", function() vim.diagnostic.open_float() end)                  -- [D]iagnostics
keymap.set("n", "K", function() vim.lsp.buf.hover() end)
-- overriding default behaviour with snacks picker
keymap.set("n", "gd", function() require("snacks").picker.lsp_definitions() end)      -- [g]o to [d]efinition
keymap.set("n", "gt", function() require("snacks").picker.lsp_type_definitions() end) -- [g]o to [t]ype definition
keymap.set("n", "grr", function() require("snacks").picker.lsp_references() end)
keymap.set("n", "gri", function() require("snacks").picker.lsp_implementations() end)

-- move selected code when in visual mode
keymap.set("v", "<S-j>", ":m '>+1<CR>gv=gv", { silent = true })
keymap.set("v", "<S-k>", ":m '<-2<CR>gv=gv", { silent = true })

-- keep cursor in middle when jumping through files
keymap.set("n", "<C-d>", "<C-d>zz")
keymap.set("n", "<C-u>", "<C-u>zz")
keymap.set("n", "n", "nzzzv")
keymap.set("n", "N", "Nzzzv")

-- harpooon (supercharged [m]arks)
keymap.set("n", "M", function() -- [M]arks
  local harpoon = require("harpoon")
  harpoon.ui:toggle_quick_menu(harpoon:list(), { title = "" })
end)
keymap.set("n", "mm", function() require("harpoon"):list():add() end)    -- [m]ake [m]ark
for i, key in ipairs({ "w", "f", "p", "r", "s", "t", "x", "c", "v" }) do -- corresponds to numpad on my keyboard layout
  local f = function()
    require("harpoon"):list():select(i)
  end
  keymap.set("n", "m" .. key, f)
  keymap.set("n", "m" .. i, f)
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
command.set("Chat", ":CopilotChat<cr>", { nargs = 0, range = true })

-- misc
keymap.set("n", "\\", function() require("oil").open() end, { silent = true })
keymap.set("n", "<C-e>", function() require("snacks").explorer.reveal() end, { silent = true })
keymap.set("n", "<leader>y", '<cmd>let @+=@" | echo "Copied to system clipboard"<cr>', { silent = true })
command.set("PackUpdate", function() vim.pack.update() end, { nargs = 0 })

-- copy the absolute or relative path of the current file to the clipboard
command.set("Path", function(opts)
  local file_path = vim.api.nvim_buf_get_name(0)
  local get_full_path = opts.args == "full"
  local requested_path = get_full_path and file_path or vim.fn.fnamemodify(file_path, ":p:.")
  local cmd = string.format('let @+="%s"', requested_path)
  vim.cmd(cmd)
end, { nargs = "?" })

-- typo guards
command.set("Q", function() vim.cmd(":q") end, { nargs = 0 })
command.set("QA", function() vim.cmd(":qa") end, { nargs = 0 })
command.set("Qa", function() vim.cmd(":qa") end, { nargs = 0 })
command.set("W", function() vim.cmd(":w") end, { nargs = 0 })
command.set("WA", function() vim.cmd(":wa") end, { nargs = 0 })
command.set("Wa", function() vim.cmd(":wa") end, { nargs = 0 })
command.set("Wqa", function() vim.cmd(":wqa") end, { nargs = 0 })

