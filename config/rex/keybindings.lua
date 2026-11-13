local utils = require("utils")

local prefix = "ctrl+b"

-- Modes ----------------------------------------------------------------------
-- Modes are exclusive: keys they don't bind are ignored rather than reaching
-- the terminal. The prefix and float modes are one-shot, so they end after a
-- single key. Resize stays active until it is exited.

local modes = {
  prefix = { once = true },
  float = { once = true },
  resize = {},
}

local bind_in = {}
for name, opts in pairs(modes) do
  rex.mode(name, { exclusive = true })
  bind_in[name] = function(key, action, args)
    rex.bind(name .. "/" .. key, action, args)
  end

  if name ~= "resize" then
    bind_in[name]("escape", "client.mode.exit")
  end
end

local enter_mode = function(name)
  return "client.mode.enter", { name = name, once = modes[name].once }
end

local bind_prefix = bind_in.prefix
local bind_float = bind_in.float
local bind_resize = bind_in.resize

rex.bind(prefix, enter_mode("prefix"))

-- Panes ----------------------------------------------------------------------
bind_prefix("v", "pane.split.right")
bind_prefix("-", "pane.split.down")
bind_prefix("enter", "pane.split.auto")

bind_prefix("h", "pane.focus.left")
bind_prefix("j", "pane.focus.down")
bind_prefix("k", "pane.focus.up")
bind_prefix("l", "pane.focus.right")
rex.bind("alt+l", "pane.focus_previous")

bind_prefix("shift+h", "pane.move.left")
bind_prefix("shift+j", "pane.move.down")
bind_prefix("shift+k", "pane.move.up")
bind_prefix("shift+l", "pane.move.right")

bind_prefix("x", "pane.close")
bind_prefix("z", "pane.zoom")
bind_prefix("o", "pane.balance")
rex.bind("alt+k", "com.superlogical.terminal.clear")

-- Resize mode: prefix+r, then h/j/k/l or the arrow keys. Esc or enter leaves.
bind_prefix("r", enter_mode("resize"))

local resize_directions = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(resize_directions) do
  bind_resize(key, "pane.resize", { direction = direction })
  bind_resize(direction, "pane.resize", { direction = direction })
end
bind_resize("escape", "client.mode.exit")
bind_resize("enter", "client.mode.exit")

-- Float mode: prefix+f, then f to float the pane or m to minimize floating ones
bind_prefix("f", enter_mode("float"))
bind_float("f", "pane.float")
bind_float("m", "pane.minimize_floating")

-- Popups ---------------------------------------------------------------------
utils.define_popup("notarizer", { "notarizer" })

local sessionizer = utils.define_popup("sessionizer", { "sessionizer", "--rex" })
rex.bind("alt+shift+s", sessionizer)

-- Misc -----------------------------------------------------------------------
rex.bind("cmd+s", "client.sidebar.toggle")
bind_prefix("shift+r", "client.config.reload")
