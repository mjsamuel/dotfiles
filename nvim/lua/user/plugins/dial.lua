local M = { "monaqa/dial.nvim" }

M.keys = {
	{
		"<C-a>",
		function()
			return require("dial.map").inc_normal()
		end,
		expr = true,
	},
	{
		"<C-x>",
		function()
			return require("dial.map").dec_normal()
		end,
		expr = true,
	},
}

function M.config()
	local augend = require("dial.augend")
	require("dial.config").augends:register_group({
		default = {
			augend.integer.alias.decimal,
			augend.integer.alias.hex,
			augend.date.alias["%Y/%m/%d"],
			augend.date.alias["%Y-%m-%d"],
			augend.date.alias["%m/%d"],
			augend.date.alias["%H:%M"],
			augend.constant.alias.bool,
		},
	})
end

return M
