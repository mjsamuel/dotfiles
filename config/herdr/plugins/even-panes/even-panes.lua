#!/usr/bin/env lua
-- Evenly distributes panes in the active tab, like tmux select-layout -E.
-- Herdr plugins have no language-specific SDK, so this uses the injected
-- socket path with nc and asks jq to turn the exported JSON tree into a small
-- line-oriented format. The balancing itself is done here in Lua.

local socket_path = os.getenv("HERDR_SOCKET_PATH")
local tab_id = os.getenv("HERDR_TAB_ID")

local function nonempty(value)
  return value ~= nil and value ~= ""
end

local function shell_quote(value)
  return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function run(command)
  local process = io.popen(command)
  if not process then
    return "", false
  end
  local output = process:read("*a") or ""
  local ok = process:close()
  return output, ok and true or false
end

if not nonempty(socket_path) then
  io.stderr:write("even-panes: HERDR_SOCKET_PATH is not set\n")
  os.exit(1)
end

local export_params = nonempty(tab_id)
    and string.format([[{"tab_id":"%s"}]], tab_id)
    or "{}"
local export_request = string.format(
  [[{"id":"even_export","method":"layout.export","params":%s}]],
  export_params
)
local export_filter = [=[
  def walk($path):
    . as $node
    | ([($path | map(if . then "1" else "0" end) | join("")), $node.type, ($node.direction // "")] | @tsv),
      (if $node.type == "split" then
        ($node.first | walk($path + [false])), ($node.second | walk($path + [true]))
      else empty end);
  if .error then error(.error.message)
  else .result.layout as $layout
    | $layout.tab_id, ($layout.root | walk([]))
  end
]=]
local export_command = string.format(
  "printf '%%s\\n' %s | nc -U %s | jq -er %s 2>&1",
  shell_quote(export_request),
  shell_quote(socket_path),
  shell_quote(export_filter)
)
local output, ok = run(export_command)
if not ok then
  io.stderr:write("even-panes: could not export layout: " .. output)
  os.exit(1)
end

local lines = {}
for line in output:gmatch("[^\r\n]+") do
  table.insert(lines, line)
end

tab_id = table.remove(lines, 1)
if not nonempty(tab_id) then
  io.stderr:write("even-panes: layout export did not include a tab id\n")
  os.exit(1)
end

local nodes = {}
local split_paths = {}
for _, line in ipairs(lines) do
  local path, node_type, direction = line:match("^(.-)\t(.-)\t(.*)$")
  if path then
    nodes[path] = { type = node_type, direction = direction }
    if node_type == "split" then
      table.insert(split_paths, path)
    end
  end
end

-- Count the equal-width columns or equal-height rows represented by a subtree.
-- A split on the axis being balanced adds its children; a perpendicular split
-- overlays their spans, so the larger child determines the required span.
local function axis_span(path, direction)
  local node = assert(nodes[path], "missing layout node at " .. path)
  if node.type == "pane" then
    return 1
  end

  local first = axis_span(path .. "0", direction)
  local second = axis_span(path .. "1", direction)
  if node.direction == direction then
    return first + second
  end
  return math.max(first, second)
end

table.sort(split_paths, function(left, right)
  return #left < #right or (#left == #right and left < right)
end)

local function path_json(path)
  local values = {}
  for bit in path:gmatch(".") do
    table.insert(values, bit == "1" and "true" or "false")
  end
  return "[" .. table.concat(values, ",") .. "]"
end

for index, path in ipairs(split_paths) do
  local node = nodes[path]
  local first = axis_span(path .. "0", node.direction)
  local second = axis_span(path .. "1", node.direction)
  local ratio = first / (first + second)
  local request = string.format(
    [[{"id":"even_ratio_%d","method":"layout.set_split_ratio","params":{"tab_id":"%s","path":%s,"ratio":%.17g}}]],
    index,
    tab_id,
    path_json(path),
    ratio
  )
  local command = string.format(
    "printf '%%s\\n' %s | nc -U %s | jq -e 'if .error then error(.error.message) else .result end' >/dev/null",
    shell_quote(request),
    shell_quote(socket_path)
  )
  local _, resize_ok = run(command)
  if not resize_ok then
    io.stderr:write("even-panes: failed to resize split " .. path .. "\n")
    os.exit(1)
  end
end
