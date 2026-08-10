#!/usr/bin/env lua
-- Tracks a most-recent-first history of focused ids per key (workspace_id
-- for tabs, a fixed key for the single global workspace slot) so
-- toggle.lua can jump back to whatever was focused before the current
-- tab/workspace, tmux last-window/switch-client -l style. herdr's own
-- focus events carry no "previous" field, so this hook rebuilds the
-- history itself on every fire.
--
-- A full history (not just a single "previous" pointer) matters because a
-- 2-slot pointer breaks the moment the tab/workspace it points at gets
-- closed - toggle.lua then has nothing to fall back to. tmux avoids this by
-- tracking the whole recency order; keeping more than one entry here lets
-- toggle.lua skip past anything that's since closed and land on the next
-- most recent live one instead.
--
-- Invoked by an [[events]] hook on every tab.focused/workspace.focused
-- event; arg[1] selects which one ("tab" or "workspace").

local kind = arg[1]
local STATE_DIR = os.getenv("HERDR_PLUGIN_STATE_DIR")

local function trim(s)
  return (s:gsub("%s+$", ""))
end

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

local function jq(cmd_that_outputs_json, filter, extra_args)
  local out = run(string.format("%s | jq -r %s %s 2>/dev/null", cmd_that_outputs_json, extra_args or "", shell_quote(filter)))
  out = trim(out)
  if out == "" or out == "null" then
    return nil
  end
  return out
end

local function nonempty(s)
  return s ~= nil and s ~= ""
end

local file, focus_id, key
if kind == "tab" then
  file = STATE_DIR .. "/last-tab.json"
  focus_id = os.getenv("HERDR_TAB_ID")
  key = os.getenv("HERDR_WORKSPACE_ID")
else
  file = STATE_DIR .. "/last-workspace.json"
  focus_id = os.getenv("HERDR_WORKSPACE_ID")
  key = "_"
end

-- HERDR_TAB_ID/HERDR_WORKSPACE_ID cover it in practice; this fallback is
-- just belt-and-suspenders in case a future herdr version stops setting
-- them for some event.
if not nonempty(focus_id) or not nonempty(key) then
  local event_json = os.getenv("HERDR_PLUGIN_EVENT_JSON")
  if event_json then
    local printf_json = string.format("printf %s", shell_quote(event_json))
    if kind == "tab" then
      focus_id = jq(printf_json, ".data.tab_id")
      key = jq(printf_json, ".data.workspace_id")
    else
      focus_id = jq(printf_json, ".data.workspace_id")
      key = "_"
    end
  end
end

if not nonempty(focus_id) or not nonempty(key) then
  os.exit(0)
end

-- Treat a missing OR empty file as unseeded: an empty file can't come back
-- from the write guard above on its own (jq has nothing to read, so it
-- keeps producing nothing), so heal it here before jq ever sees it.
local existing = io.open(file, "r")
local needs_seed = true
if existing then
  local content = existing:read("*a")
  existing:close()
  needs_seed = content == nil or trim(content) == ""
end
if needs_seed then
  local f = assert(io.open(file, "w"))
  f:write("{}")
  f:close()
end

-- Move $cur to the front of its key's history, deduping any earlier
-- occurrence, capped to the 8 most recent entries.
--
-- Writes through a mktemp-generated tmp file (unique per invocation, not a
-- fixed file..".tmp" path) so concurrent events for the same kind can't
-- clobber each other's in-flight write. And the `[ -s "$tmp" ]` check refuses
-- to `mv` an empty result over good state - jq exits 0 with no output on
-- empty/invalid input rather than erroring, so without this guard a single
-- corrupted read silently propagates forever (every future run reads the
-- empty file, "succeeds" with empty output, and moves that back over itself).
local filter = [=[.[$key] = ([$cur] + ((.[$key] // []) - [$cur]))[0:8]]=]
local cmd = string.format(
  "tmp=$(mktemp %s.XXXXXX) && jq --arg key %s --arg cur %s %s %s > \"$tmp\" 2>/dev/null "
    .. "&& [ -s \"$tmp\" ] && mv \"$tmp\" %s || rm -f \"$tmp\"",
  shell_quote(file),
  shell_quote(key),
  shell_quote(focus_id),
  shell_quote(filter),
  shell_quote(file),
  shell_quote(file)
)
os.execute(cmd)
