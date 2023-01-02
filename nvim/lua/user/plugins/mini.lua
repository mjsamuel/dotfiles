local M = {
	"echasnovski/mini.nvim",
	event = "VeryLazy",
	dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
}

function M.config()
	require("mini.pairs").setup({})

	require("mini.comment").setup({
		hooks = {
			pre = function()
				require("ts_context_commentstring.internal").update_commentstring({})
			end,
		},
	})
end

function M.init()
	vim.keymap.set("n", "<leader>bd", function()
		require("mini.bufremove").delete(0, false)
	end)
	vim.keymap.set("n", "<leader>bD", function()
		require("mini.bufremove").delete(0, true)
	end)
end

return M
