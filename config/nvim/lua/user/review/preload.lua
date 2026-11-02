local M = {}

function M.start(active, base)
  local buffers, seen = {}, {}
  for _, item in ipairs(vim.fn.getqflist()) do
    if item.bufnr > 0 and not seen[item.bufnr] then
      seen[item.bufnr] = true
      buffers[#buffers + 1] = item.bufnr
    end
  end
  local index = 0
  local function load_next()
    if not active() then return end
    index = index + 1
    local buf = buffers[index]
    if not buf then return end
    local function next_buffer() vim.schedule(load_next) end
    if not vim.api.nvim_buf_is_valid(buf) then return next_buffer() end
    local filename = vim.api.nvim_buf_get_name(buf)
    if not vim.api.nvim_buf_is_loaded(buf) and vim.fn.filereadable(filename) ~= 1 then
      return next_buffer()
    end

    vim.bo[buf].buflisted = true
    local swap = vim.api.nvim_create_autocmd("SwapExists", {
      pattern = "*",
      callback = function(event)
        if vim.fn.resolve(event.file) == vim.fn.resolve(filename) then
          vim.v.swapchoice = "o"
        end
      end,
    })
    -- Gitsigns defers diff calculation unless the buffer belongs to a window.
    local opened, win = pcall(vim.api.nvim_open_win, 0, false, {
      relative = "editor", row = 0, col = 0, width = 1, height = 1,
      hide = true, focusable = false, noautocmd = true,
    })
    if not opened then
      vim.api.nvim_del_autocmd(swap)
      return next_buffer()
    end
    local shortmess = vim.o.shortmess
    vim.o.shortmess = shortmess:gsub("A", "")
    local loaded, load_err = pcall(vim.api.nvim_win_call, win, function()
      -- Unlike bufload(), :buffer allows SwapExists to choose read-only mode.
      vim.cmd("silent keepalt buffer " .. buf)
    end)
    vim.o.shortmess = shortmess
    vim.api.nvim_del_autocmd(swap)
    if not loaded or not active() then
      vim.api.nvim_win_close(win, true)
      if not loaded then
        vim.notify("Review: could not preload " .. filename .. ": " .. tostring(load_err), vim.log.levels.WARN)
      end
      return next_buffer()
    end
    local finished = false
    local function finish(err)
      if finished then return end
      finished = true
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
      if err and active() then
        vim.notify("Review: could not warm Gitsigns for " .. filename .. ": " .. tostring(err), vim.log.levels.WARN)
      end
      next_buffer()
    end
    local deadline = vim.uv.now() + 5000
    local requested = false
    local function check()
      if finished then return end
      if not active() or not vim.api.nvim_buf_is_valid(buf) then return finish() end
      -- get_hunks() returns {} both before calculation and for an unchanged file.
      local cache = require("gitsigns.cache").cache[buf]
      if requested and cache and cache.hunks ~= nil then return finish() end
      if vim.uv.now() >= deadline then return finish("diff warmup timed out") end
      vim.defer_fn(check, 25)
    end
    check()
    local gitsigns = require("gitsigns")
    local ok, err = pcall(gitsigns.attach, { bufnr = buf }, function(attach_err)
      if finished then return end
      if attach_err or not active() or not vim.api.nvim_buf_is_valid(buf) then return finish(attach_err) end
      local changed, change_err = pcall(vim.api.nvim_buf_call, buf, function()
        -- Also update already-attached buffers whose initial diff was deferred.
        gitsigns.change_base(base, false, function(err)
          if err then return finish(err) end
          requested = true
        end)
      end)
      if not changed then finish(change_err) end
    end)
    if not ok then finish(err) end
  end
  vim.schedule(load_next)
end

return M
