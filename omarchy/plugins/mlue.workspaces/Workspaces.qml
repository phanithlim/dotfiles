import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

// Per-monitor workspace indicators, for use with split-monitor-workspaces.
//
// Each monitor owns a contiguous block of Hyprland workspace ids (monitor 1
// gets 1-10, monitor 2 gets 11-20, ...). This widget shows only the block
// belonging to the monitor its bar lives on, labelled 1-10 rather than by the
// underlying id.
BarWidget {
  id: root
  moduleName: "mlue.workspaces"

  // How many workspaces split-monitor-workspaces gives each monitor. Must
  // match workspace_count in ~/.config/hypr/split-monitor-workspaces.lua.
  readonly property int workspacesPerMonitor: 10

  // Slots that are always drawn, even while empty.
  readonly property int alwaysVisible: 5

  readonly property var barScreen: root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property var hyprMonitor: barScreen ? Hyprland.monitorFor(barScreen) : null

  // First id in this monitor's block, derived from whatever it currently
  // shows, so the widget doesn't need to know the monitor ordering.
  readonly property int blockStart: {
    var workspace = hyprMonitor ? hyprMonitor.activeWorkspace : null
    if (!workspace || workspace.id < 1) return 1
    return Math.floor((workspace.id - 1) / workspacesPerMonitor) * workspacesPerMonitor + 1
  }

  function workspaceById(id) {
    var values = Hyprland.workspaces.values
    for (var i = 0; i < values.length; i++) {
      if (values[i].id === id) return values[i]
    }

    return null
  }

  // This monitor's ids: the first `alwaysVisible` slots, plus any further
  // workspace in the block that currently exists.
  function workspaceIds() {
    var ids = []
    for (var i = 0; i < alwaysVisible; i++) ids.push(blockStart + i)

    var values = Hyprland.workspaces.values
    for (var j = 0; j < values.length; j++) {
      var id = values[j].id
      if (id >= blockStart && id < blockStart + workspacesPerMonitor && ids.indexOf(id) === -1) ids.push(id)
    }

    ids.sort(function(left, right) { return left - right })
    return ids
  }

  // 1-based position within the monitor's block, with 10 shown as "0".
  function workspaceLabel(id) {
    var index = id - blockStart + 1
    return index === 10 ? "0" : String(index)
  }

  // Every slot is sized for the bracketed form, so the row doesn't shift as
  // the active workspace moves along it.
  TextMetrics {
    id: slotMetrics
    font.family: root.bar ? root.bar.fontFamily : Style.font.family
    font.pixelSize: Style.font.body
    text: "[0]"
  }

  function focusWorkspace(id) {
    if (!root.bar) return
    root.bar.run("hyprctl dispatch " + Util.shellQuote("hl.dsp.focus({ workspace = \"" + id + "\" })"))
  }

  readonly property real trailingGap: root.vertical ? 0 : Style.spaceReal(1.5)

  implicitWidth: grid.implicitWidth + trailingGap
  implicitHeight: grid.implicitHeight

  GridLayout {
    id: grid
    anchors.fill: parent
    anchors.rightMargin: root.trailingGap
    columns: root.vertical ? 1 : root.workspaceIds().length
    columnSpacing: root.vertical ? 0 : Style.space(1)
    rowSpacing: root.vertical ? Style.space(2) : 0

    Repeater {
      model: root.workspaceIds()

      WidgetButton {
        id: slot
        required property int modelData

        readonly property var workspace: root.workspaceById(modelData)
        readonly property bool occupied: workspace !== null && workspace.toplevels.values.length > 0

        // Active on *this* monitor, not globally: every bar highlights the
        // workspace its own output is showing.
        readonly property bool focused: root.hyprMonitor !== null
          && root.hyprMonitor.activeWorkspace !== null
          && root.hyprMonitor.activeWorkspace.id === modelData

        bar: root.bar

        // Always show the number, bracketed when it's the active one. Stock
        // Omarchy swaps the active number for a dot, which hides the only
        // label you actually want to read.
        text: focused
          ? "[" + root.workspaceLabel(modelData) + "]"
          : root.workspaceLabel(modelData)

        opacity: occupied || focused ? 1 : 0.5
        horizontalMargin: 6
        verticalPadding: 6
        fixedWidth: root.vertical
          ? root.barSize
          : Math.max(Style.space(20), Math.ceil(slotMetrics.width) + Style.space(4))
        fixedHeight: root.barSize
        onPressed: function() { root.focusWorkspace(modelData) }
      }
    }
  }
}
