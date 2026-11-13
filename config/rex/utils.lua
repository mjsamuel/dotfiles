local M = {}

-- Define an action that opens a command in a floating window covering most of
-- the screen. Modes can only bind actions by name, so popups need to be actions
M.define_popup = function(name, command)
  rex.action({
    name = name,
    title = name,
    run = function()
      rex.session.new_layer({
        bounds = { 0.1, 0.1, 0.8, 0.8 },
        focus = true,
        layout = {
          block = {
            flavor = "com.superlogical.terminal.shell",
            options = { command = command },
          },
        },
      })
      return true
    end,
  })
  return name
end

return M
