local M = {}

-- Bind one or more keys to the same action. `keys` is either a single key
-- string or a list of them. Keys scoped to a mode use "mode/key", so global
-- and mode bindings can be mixed:
--   bind({ "alt+l", "prefix/l", "prefix/right" }, "pane.focus.right")
M.bind = function(keys, action, args)
  if type(keys) == "string" then
    keys = { keys }
  end
  for _, key in ipairs(keys) do
    rex.bind(key, action, args)
  end
end

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
            options = { command = command, interactive = true },
          },
        },
      })
      return true
    end,
  })
  return name
end

return M
