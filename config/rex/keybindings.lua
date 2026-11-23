local utils = require("utils")

local bind = utils.bind
local prefix = "ctrl+b"

-- Modes ----------------------------------------------------------------------
-- Modes are exclusive: keys they don't bind are ignored rather than reaching
-- the terminal. The prefix and float modes are one-shot, so they end after a
-- single key. Resize stays active until it is exited.
--
-- Keys inside a mode are bound as "mode/key", e.g. "prefix/h".

local modes = {
  prefix = { once = true },
  float = { once = true },
  resize = {},
}

for name in pairs(modes) do
  rex.mode(name, { exclusive = true })
  bind(name .. "/escape", "client.mode.exit")
end

local enter_mode = function(name)
  return "client.mode.enter", { name = name, once = modes[name].once }
end

bind(prefix, enter_mode("prefix"))

-- Panes ----------------------------------------------------------------------
bind({ "prefix/v", "alt+v" }, "pane.split.right")
bind({ "prefix/-", "alt+-" }, "pane.split.down")
bind("prefix/enter", "pane.split.auto")

bind({ "prefix/h", "alt+h" }, "pane.focus.left")
bind({ "prefix/j", "alt+j" }, "pane.focus.down")
bind({ "prefix/k", "alt+k" }, "pane.focus.up")
bind({ "prefix/l", "alt+l" }, "pane.focus.right")
bind("alt+p", "pane.focus_previous")

bind({ "prefix/shift+h", "alt+shift+h" }, "pane.move.left")
bind({ "prefix/shift+j", "alt+shift+j" }, "pane.move.down")
bind({ "prefix/shift+k", "alt+shift+k" }, "pane.move.up")
bind({ "prefix/shift+l", "alt+shift+l" }, "pane.move.right")

bind({ "prefix/z", "alt+z" }, "pane.zoom")
bind({ "prefix/o", "alt+o" }, "pane.balance")
bind("prefix/x", "pane.close")
bind("alt+shift+k", "com.superlogical.terminal.clear")

-- Resize mode: prefix+r, then h/j/k/l or the arrow keys. Esc or enter leaves.
bind("prefix/r", enter_mode("resize"))

local resize_directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(resize_directions) do
  bind({ "resize/" .. key, "resize/" .. direction }, "pane.resize", { direction = direction })
end
bind("resize/enter", "client.mode.exit")

-- Float mode: prefix+f, then f to float the pane or m to minimize floating ones
bind("prefix/f", enter_mode("float"))
bind("float/f", "pane.float")
bind("float/m", "pane.minimize_floating")

-- Popups ---------------------------------------------------------------------
utils.define_popup("notarizer", { "notarizer" })

local sessionizer = utils.define_popup("sessionizer", { "sessionizer", "--rex" })
bind("alt+shift+s", sessionizer)

-- Misc -----------------------------------------------------------------------
bind("cmd+s", "client.sidebar.toggle")
bind("prefix/shift+r", "client.config.reload")
