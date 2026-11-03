local prefix = "ctrl+b"
local bind_prefix = function(key, action, args)
  local prefixed_key = prefix .. ">" .. key
  rex.bind(prefixed_key, action, args)
end

-- Open a command in a floating window covering most of the screen
local popup = function(command)
  return function()
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
  end
end

-- Press prefix twice to send it once to the terminal
bind_prefix(prefix, "pane.send_key", { key = prefix })

-- Panes
bind_prefix("v", "pane.split.right")
bind_prefix("-", "pane.split.down")
bind_prefix("enter", "pane.split.auto")

bind_prefix("h", "pane.focus.left")
bind_prefix("j", "pane.focus.down")
bind_prefix("k", "pane.focus.up")
bind_prefix("l", "pane.focus.right")

bind_prefix("z", "pane.zoom")
bind_prefix("o", "pane.balance")
rex.bind("alt+l", "pane.focus_previous")
rex.bind("alt+k", "com.superlogical.terminal.clear")

bind_prefix("f>f", "pane.float")
bind_prefix("f>m", "pane.minimize_floating")

-- Tabs
for i = 1, 9 do
  bind_prefix(tostring(i), "client.tab.goto", { index = i })
  rex.bind("alt+" .. i, "client.tab.goto", { index = i })
end

-- Popups
rex.bind("alt+shift+s", popup({ "sessionizer", "--rex" }))
bind_prefix("s", popup({ "sessionizer", "--rex" }))
bind_prefix("n", popup({ "notarizer" }))
bind_prefix("p", popup({ os.getenv("SHELL") or "sh" }))
