import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "jlord.mouse-focus"
  readonly property string pluginVersion: "0.2.1"

  readonly property var modes: [
    { value: 0, name: "Click", description: "Focus changes when you click a window." },
    { value: 1, name: "Hover", description: "Focus follows the pointer." },
    { value: 2, name: "Hover on entry", description: "Focus changes when entering another window." },
    { value: 3, name: "Hover through floating", description: "Focus follows the pointer through floating windows." }
  ]
  property int currentMode: 2
  property bool popupOpen: false
  property string statusMessage: ""
  property int pendingMode: -1

  readonly property var activeMode: modeForValue(currentMode)
  readonly property string iconText: "\uE8D4"

  function modeForValue(value) {
    for (var i = 0; i < modes.length; i++) {
      if (modes[i].value === value) return modes[i]
    }
    return modes[0]
  }

  function refresh() {
    queryProcess.running = true
  }

  function applyMode(mode) {
    if (mode.value === currentMode) return
    var config = "-- Managed by jlord.mouse-focus.\\nhl.config({\\n  input = {\\n    follow_mouse = " + mode.value + ",\\n  },\\n})\\n"
    applyProcess.command = ["bash", "-lc", "printf '%b' \"" + config + "\" > \"$HOME/.config/hypr/mouse-focus.lua\" && hyprctl reload"]
    applyProcess.running = true
    pendingMode = mode.value
  }

  function cycleMode() {
    var nextIndex = 0
    for (var i = 0; i < modes.length; i++) {
      if (modes[i].value === currentMode) {
        nextIndex = (i + 1) % modes.length
        break
      }
    }
    applyMode(modes[nextIndex])
  }

  function resetMode() {
    applyMode({ value: 1, name: "Hover", description: "Focus follows the pointer." })
  }

  function showError() {
    statusMessage = "Could not apply mouse focus mode"
    if (root.bar) root.bar.run("notify-send -u critical 'Mouse focus' 'Could not apply the selected mode'")
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  Component.onCompleted: refresh()

  Timer {
    interval: 1500
    running: true
    repeat: true
    onTriggered: root.refresh()
  }

  Process {
    id: queryProcess
    command: ["hyprctl", "getoption", "input:follow_mouse", "-j"]
    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: {
        try {
          var result = JSON.parse(text || "{}")
          if (result.int !== undefined && result.int >= 0 && result.int <= 3)
            root.currentMode = result.int
        } catch (error) {
        }
      }
    }
  }

  Process {
    id: applyProcess
    onExited: function(exitCode) {
      if (exitCode === 0) {
        root.currentMode = root.pendingMode
        root.statusMessage = ""
      } else {
        root.showError()
      }
      root.pendingMode = -1
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.iconText
    fontFamily: "omarchy"
    horizontalMargin: 7.5
    tooltipText: "Mouse focus: " + root.activeMode.name
      + "\nLeft click: Cycle mode"
      + "\nRight click: Choose mode"
      + "\nVersion: " + root.pluginVersion
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.cycleMode()
      else if (mouseButton === Qt.RightButton) root.popupOpen = !root.popupOpen
      else if (mouseButton === Qt.MiddleButton) root.refresh()
    }
  }

  PanelWindow {
    id: popup
    visible: root.popupOpen
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "jlord-mouse-focus"
    WlrLayershell.layer: WlrLayer.Overlay

    MouseArea {
      anchors.fill: parent
      onClicked: root.popupOpen = false
    }

    Rectangle {
      id: card
      anchors.centerIn: parent
      implicitWidth: Style.space(250)
      implicitHeight: content.implicitHeight + Style.space(24)
      color: "#202020"
      border.color: "#666666"
      border.width: 1
      radius: Style.cornerRadius

      focus: true
      Keys.onEscapePressed: root.popupOpen = false

      MouseArea {
        anchors.fill: parent
        onClicked: mouse.accepted = true
      }

      Column {
        id: content
        anchors.fill: parent
        anchors.margins: Style.space(12)
        spacing: Style.space(4)

        Text {
          text: "MOUSE FOCUS"
          color: "#ffffff"
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
          font.bold: true
        }

        Repeater {
          model: root.modes

          Button {
            required property var modelData
            width: content.width
            text: modelData.name
            tooltipText: modelData.description
            selected: modelData.value === root.currentMode
            bordered: true
            leftAlign: true
            foreground: "#ffffff"
            fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
            onClicked: {
              root.applyMode(modelData)
              root.popupOpen = false
            }
          }
        }

        Text {
          text: "Right click: reset to Hyprland default"
          color: "#ffffff"
          opacity: 0.6
          font.family: root.bar ? root.bar.fontFamily : Style.font.family
          font.pixelSize: Style.font.caption
        }
      }
    }
  }
}
