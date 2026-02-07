local PLUGIN_DIR = vim.fn.stdpath("config") .. "/lua/user/plugins"

vim.iter(vim.fs.dir(PLUGIN_DIR))
   :filter(function(filename) return filename ~= "init.lua" end)
   :map(function(filename) return filename:gsub("%.lua$", "") end)
   :each(function(name) require("user.plugins." .. name) end)
