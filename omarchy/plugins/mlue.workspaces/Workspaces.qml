import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "mlue.workspaces"

  readonly property int workspacesPerMonitor: 10

  readonly property int alwaysVisible: 5

  readonly property var barScreen: root.QsWindow.window ? root.QsWindow.window.screen : null
  readonly property var hyprMonitor: barScreen ? Hyprland.monitorFor(barScreen) : null

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

  function workspaceLabel(id) {
    var index = id - blockStart + 1
    return index === 10 ? "0" : String(index)
  }

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

        readonly property bool focused: root.hyprMonitor !== null
          && root.hyprMonitor.activeWorkspace !== null
          && root.hyprMonitor.activeWorkspace.id === modelData

        bar: root.bar

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
