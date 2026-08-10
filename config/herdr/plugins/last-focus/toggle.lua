#!/usr/bin/env lua
-- Toggles back to whichever tab/workspace was most recently focused before
-- the current one, using the recency history record.lua's event hooks
-- build. tmux last-window/switch-client -l equivalents.
--
-- Walks the whole history (not just a single "previous" slot) and skips
-- anything that's since been closed, landing on the next most recent
-- live entry - so closing a tab/workspace doesn't strand the toggle with
-- nothing to fall back to.
--
-- Gathers current/key/valid-ids/history in a single herdr-list-piped-into-
-- jq call rather than several separate io.popen round trips - each
-- io.popen forks its own shell, and that overhead is what makes this feel
-- laggy, not the lua interpreter itself.
--
-- Invoked as a plugin action (herdr plugin action invoke); arg[1] selects
-- which one ("tab" or "workspace").

local kind = arg[1]
local STATE_DIR = os.getenv("HERDR_PLUGIN_STATE_DIR")

local function shell_quote(s)
  return "'" .. tostring(s):gsub("'", "'\\''") .. "'"
end

local function run(cmd)
  local proc = io.popen(cmd)
  if not proc then
    return "", false
  end
  local output = proc:read("*a") or ""
  local ok = proc:close()
  return output, ok and true or false
end

local function split_lines(s)
  local lines = {}
  local start = 1
  while true do
    local nl = s:find("\n", start)
    if not nl then
      if start <= #s then
        table.insert(lines, s:sub(start))
      end
      break
    end
    table.insert(lines, s:sub(start, nl - 1))
    start = nl + 1
  end
  return lines
end

local function split_csv(s)
  local t = {}
  if s == "" then
    return t
  end
  for part in (s .. ","):gmatch("([^,]*),") do
    table.insert(t, part)
  end
  return t
end

local file, list_cmd, filter
if kind == "tab" then
  file = STATE_DIR .. "/last-tab.json"
  list_cmd = "herdr tab list 2>/dev/null"
  filter = [=[
    ([.result.tabs[] | select(.focused)][0] // {}) as $f
    | ($f.tab_id // "") as $cur
    | ($f.workspace_id // "") as $key
    | [.result.tabs[].tab_id] as $valid
    | ($state[0][$key] // []) as $hist
    | [$cur, $key, ($valid | join(",")), ($hist | join(","))] | .[]
  ]=]
else
  file = STATE_DIR .. "/last-workspace.json"
  list_cmd = "herdr workspace list 2>/dev/null"
  filter = [=[
    ([.result.workspaces[] | select(.focused)][0] // {}) as $f
    | ($f.workspace_id // "") as $cur
    | "_" as $key
    | [.result.workspaces[].workspace_id] as $valid
    | ($state[0][$key] // []) as $hist
    | [$cur, $key, ($valid | join(",")), ($hist | join(","))] | .[]
  ]=]
end

if not io.open(file, "r") then
  local f = assert(io.open(file, "w"))
  f:write("{}")
  f:close()
end

local out = run(string.format(
  "%s | jq -r --slurpfile state %s %s 2>/dev/null",
  list_cmd,
  shell_quote(file),
  shell_quote(filter)
))

local lines = split_lines(out)
local current_id = lines[1] or ""
local key = lines[2] or ""
local valid_ids = split_csv(lines[3] or "")
local history = split_csv(lines[4] or "")

if key == "" then
  os.exit(0)
end

local function is_valid(id)
  for _, v in ipairs(valid_ids) do
    if v == id then
      return true
    end
  end
  return false
end

local target = nil
for _, id in ipairs(history) do
  if id ~= current_id and is_valid(id) then
    target = id
    break
  end
end

if target == nil then
  os.exit(0)
end

if kind == "tab" then
  os.execute(string.format("herdr tab focus %s >/dev/null 2>&1", shell_quote(target)))
else
  os.execute(string.format("herdr workspace focus %s >/dev/null 2>&1", shell_quote(target)))
end
