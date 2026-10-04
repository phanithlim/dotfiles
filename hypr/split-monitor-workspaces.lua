-- Independent, per-monitor workspaces (awesome/dwm style).
-- https://github.com/zjeffer/split-monitor-workspaces
--
-- Each monitor gets its own 1..10. Under the hood the first monitor owns
-- workspace IDs 1-10, the second 11-20, and so on.
--
-- Update after every Hyprland release:
--   cd ~/.config/hypr/plugins/split-monitor-workspaces
--   git fetch -Ppft && git checkout release/<hyprland minor>.x && git pull

-- Omarchy's bootstrap puts ~/.config/?.lua on the path; the library is a
-- directory module, so it also needs ~/.config/?/init.lua.
package.path = package.path .. ";" .. (os.getenv("HOME") or "") .. "/.config/?/init.lua"

local smw = require("hypr.plugins.split-monitor-workspaces")

smw.setup({
  workspace_count = 10,
  keep_focused = true,
  enable_notifications = false,
  enable_persistent_workspaces = false,
})

-- Move the active window to whatever workspace is showing on another monitor,
-- without following it. Hyprland's Lua API has no "move window to monitor"
-- dispatcher, so resolve the monitor's active workspace and move there.
local function move_window_to_monitor(selector)
  return function()
    local monitor = hl.get_monitor(selector)
    if not monitor or not monitor.active_workspace then
      return
    end

    hl.dispatch(hl.dsp.window.move({ workspace = tostring(monitor.active_workspace.id), follow = false }))
  end
end

-- Workspaces: swap Omarchy's global bindings for per-monitor ones.
for index = 1, 10 do
  local key = "code:" .. tostring(index + 9)
  local workspace = tostring(index)

  hl.unbind("SUPER + " .. key)
  hl.unbind("SUPER + SHIFT + " .. key)
  hl.unbind("SUPER + SHIFT + ALT + " .. key)

  o.bind("SUPER + " .. key, "Switch to workspace " .. workspace, smw.workspace(workspace))
  o.bind("SUPER + SHIFT + " .. key, "Move window to workspace " .. workspace, smw.move_to_workspace(workspace))
  o.bind(
    "SUPER + SHIFT + ALT + " .. key,
    "Move window silently to workspace " .. workspace,
    smw.move_to_workspace_silent(workspace)
  )
end

-- Cycle workspaces on the focused monitor, skipping the empty ones.
--
-- smw.cycle_workspaces() walks the monitor's full 1..10 list, so going from 6
-- to 10 means four presses through three empty workspaces. This stops only on
-- workspaces that actually hold windows.
local function cycle_occupied(step)
  return function()
    local monitor = hl.get_active_monitor()
    local active = monitor and monitor.active_workspace
    if not active then
      return
    end

    -- This monitor's occupied workspaces, plus wherever we are right now.
    local stops = {}
    for _, workspace in ipairs(hl.get_workspaces()) do
      if
        not workspace.special
        and workspace.id > 0
        and workspace.monitor
        and workspace.monitor.id == monitor.id
        and (workspace.id == active.id or not workspace.is_empty)
      then
        table.insert(stops, workspace.id)
      end
    end

    if #stops < 2 then
      return
    end

    table.sort(stops)

    local index
    for position, id in ipairs(stops) do
      if id == active.id then
        index = position
        break
      end
    end

    if not index then
      return
    end

    -- Wrap around at both ends.
    index = index + step
    if index < 1 then
      index = #stops
    elseif index > #stops then
      index = 1
    end

    hl.dispatch(hl.dsp.focus({ workspace = tostring(stops[index]) }))
  end
end

hl.unbind("SUPER + TAB")
hl.unbind("SUPER + SHIFT + TAB")
hl.unbind("SUPER + mouse_down")
hl.unbind("SUPER + mouse_up")

o.bind("SUPER + TAB", "Next occupied workspace", cycle_occupied(1))
o.bind("SUPER + SHIFT + TAB", "Previous occupied workspace", cycle_occupied(-1))
o.bind("SUPER + mouse_down", "Scroll active workspace forward", cycle_occupied(1))
o.bind("SUPER + mouse_up", "Scroll active workspace backward", cycle_occupied(-1))

-- Focus a monitor by position (SUPER + CTRL + 1..5).
for index = 1, 5 do
  local monitor = index - 1

  o.bind(
    "SUPER + CTRL + code:" .. tostring(index + 9),
    "Focus monitor " .. tostring(monitor),
    hl.dsp.focus({ monitor = monitor })
  )
  o.bind(
    "SUPER + CTRL + SHIFT + code:" .. tostring(index + 9),
    "Send window to monitor " .. tostring(monitor),
    move_window_to_monitor(monitor)
  )
end

-- Focus / send to the neighbouring monitor.
hl.unbind("SUPER + CTRL + LEFT")
hl.unbind("SUPER + CTRL + RIGHT")

o.bind("SUPER + CTRL + LEFT", "Focus monitor to the left", hl.dsp.focus({ monitor = "l" }))
o.bind("SUPER + CTRL + RIGHT", "Focus monitor to the right", hl.dsp.focus({ monitor = "r" }))
o.bind("SUPER + CTRL + SHIFT + LEFT", "Send window to left monitor", move_window_to_monitor("l"))
o.bind("SUPER + CTRL + SHIFT + RIGHT", "Send window to right monitor", move_window_to_monitor("r"))

-- Throw the active window between the laptop panel (eDP-*) and the external
-- monitor, and follow it: from the laptop it goes to the external monitor,
-- from anywhere else it comes back to the laptop.
local function toggle_window_monitor()
  local active = hl.get_active_monitor()
  if not active or not hl.get_active_window() then
    return
  end

  local on_laptop = active.name:match("^eDP") ~= nil
  local target
  for index = 0, 5 do
    local monitor = hl.get_monitor(index)
    if monitor and monitor.id ~= active.id and (on_laptop or monitor.name:match("^eDP")) then
      target = monitor
      break
    end
  end
  if not target or not target.active_workspace then
    return
  end

  hl.dispatch(hl.dsp.window.move({ workspace = tostring(target.active_workspace.id), follow = true }))
end

o.bind("SUPER + M", "Move window to other monitor (laptop ⇄ external)", toggle_window_monitor)

-- Collect windows stranded on an unmapped monitor or workspace.
o.bind("SUPER + CTRL + G", "Grab rogue windows", smw.grab_rogue_windows())
