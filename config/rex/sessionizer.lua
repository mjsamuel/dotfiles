-- Sessionizer: pick a project from ~/.config/workspaces and switch to its
-- session, creating the session first if it doesn't exist.
--
-- Each line of the workspaces file is one of:
--   /path/to/root      every directory directly inside root (globs allowed,
--                      e.g. ~/[Dd]eveloper)
--   @/path/to/project  that one project
--   # comment          ignored, as are blank lines

local M = {}

local home = os.getenv("HOME")
local workspaces_file = home .. "/.config/workspaces"
local default_workspaces = { home .. "/[Dd]eveloper", home .. "/[Ww]ork" }

local function lines(text)
  local out = {}
  for line in (text or ""):gmatch("[^\n]+") do
    out[#out + 1] = line
  end
  return out
end

local function read_workspaces()
  local file = io.open(workspaces_file, "r")
  if not file then
    rex.exec({ "mkdir", "-p", home .. "/.config" })
    file = assert(io.open(workspaces_file, "w"))
    file:write(table.concat(default_workspaces, "\n"), "\n")
    file:close()
    return default_workspaces
  end
  local text = file:read("*a")
  file:close()
  return lines(text)
end

-- Directories directly inside every root matching `pattern`, skipping hidden
-- ones. The shell expands the glob, as the old script did.
local list_roots = [[
for root in $1; do
  [ -d "$root" ] && find "$root" -mindepth 1 -maxdepth 1 -type d -not -path '*/.*'
done
true
]]

local function subdirs(pattern)
  local dirs = lines(rex.exec({ "sh", "-c", list_roots, "sh", pattern }).stdout)
  table.sort(dirs)
  return dirs
end

local function is_dir(path)
  return rex.exec({ "test", "-d", path }).ok
end

local function projects()
  local found, seen = {}, {}
  local function add(path)
    if not seen[path] then
      seen[path] = true
      found[#found + 1] = path
    end
  end

  for _, line in ipairs(read_workspaces()) do
    if line:match("^%s*$") or line:match("^#") then
      -- skip
    elseif line:sub(1, 1) == "@" then
      local path = line:sub(2)
      if is_dir(path) then
        add(path)
      end
    else
      for _, path in ipairs(subdirs(line)) do
        add(path)
      end
    end
  end
  return found
end

local function basename(path)
  return path:match("([^/]+)/*$") or path
end

local function dirname(path)
  return path:match("^(.*)/[^/]+/*$") or ""
end

local function tildify(path)
  if path:sub(1, #home) == home then
    return "~" .. path:sub(#home + 1)
  end
  return path
end

-- Same labels the old script used, so existing sessions are found again.
local function session_label(path)
  return (basename(path):gsub("%.", "-"))
end

local function sessions_by_label()
  local by_label = {}
  for _, session in ipairs(rex.call("session.list").sessions or {}) do
    if session.label and not by_label[session.label] then
      by_label[session.label] = session.session_id
    end
  end
  return by_label
end

-- Switch to the session for `path`, creating it with a shell in `path` first.
M.open = function(path)
  local label = session_label(path)
  local session_id = sessions_by_label()[label]

  if not session_id then
    session_id = rex.call("session.create", {
      label = label,
      initial_windows = {
        {
          layout = {
            block = {
              flavor = "com.superlogical.terminal.shell",
              options = { cwd = path },
            },
          },
        },
      },
    }).session_id
  end

  rex.client.queue("session.select", { session_id = session_id })
end

M.pick = function()
  local open = sessions_by_label()
  local items = {}
  for _, path in ipairs(projects()) do
    items[#items + 1] = {
      id = path,
      title = basename(path),
      subtitle = tildify(dirname(path)),
      icon = "folder",
      detail = open[session_label(path)] and "open" or nil,
    }
  end
  if #items == 0 then
    return
  end

  local choice = rex.ui.pick({ title = "Open project", confirm = "Open", items = items })
  -- Single-choice picks give back the chosen ID. Accept a list too, in case
  -- that changes, and nil when the prompt was closed.
  if type(choice) == "table" then
    choice = choice[1]
  end
  if choice then
    M.open(choice)
  end
end

rex.action({
  name = "sessionizer",
  title = "Sessionizer",
  run = function()
    M.pick()
    return true
  end,
})

return M
