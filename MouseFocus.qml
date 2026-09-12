import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "jlord.mouse-focus"
  readonly property string pluginVersion: "0.6.1"

  readonly property var modes: [
    { value: 0, name: "Click Focus", description: "Cursor movement will not change focus." },
    { value: 2, name: "Click Focus, scroll under pointer", description: "Cursor focus is detached from keyboard focus. Clicking on a window moves keyboard focus to that window." },
    { value: 1, name: "Hover Focus", description: "Cursor movement always changes focus to the window under the cursor." }
  ]
  property int currentMode: 2
  property bool popupOpen: false
  property bool persistEnabled: false
  property string statusMessage: ""
  property int pendingMode: -1
  property int requestedMode: -1

  readonly property var activeMode: modeForValue(currentMode)
  readonly property string iconText: "\uE8D4"

  function modeForValue(value) {
    for (var i = 0; i < modes.length; i++) {
      if (modes[i].value === value) return modes[i]
    }
    return { value: value, name: "Unsupported mode", description: "This follow_mouse value is not available from this widget." }
  }

  function refresh() {
    queryProcess.running = true
  }

  function applyMode(mode) {
    if (mode.value === currentMode) return
    applyProcess.command = ["hyprctl", "eval", "hl.config({ input = { follow_mouse = " + mode.value + " } })"]
    applyProcess.running = true
    pendingMode = mode.value
    requestedMode = mode.value
    if (persistEnabled) persistMode(mode.value)
  }

  function persistMode(value) {
    var config = "-- Managed by jlord.mouse-focus.\\nhl.config({\\n  input = {\\n    follow_mouse = " + value + ",\\n  },\\n})\\n"
    persistProcess.command = ["bash", "-lc", "set -e; mkdir -p \"$HOME/.config/hypr\"; printf '%b' \"" + config + "\" > \"$HOME/.config/hypr/mouse-focus.lua\"; touch \"$HOME/.config/hypr/input.lua\"; if ! grep -Fqx 'require(\"hypr.mouse-focus\")' \"$HOME/.config/hypr/input.lua\"; then printf '\\nrequire(\"hypr.mouse-focus\")\\n' >> \"$HOME/.config/hypr/input.lua\"; fi"]
    persistProcess.running = true
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
          if (result.int !== undefined && result.int >= 0 && result.int <= 3) {
            if (root.requestedMode === -1 || result.int === root.requestedMode) {
              root.currentMode = result.int
              if (root.requestedMode === result.int) root.requestedMode = -1
            }
          }
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
        root.requestedMode = -1
      }
      root.pendingMode = -1
    }
  }

  Process {
    id: persistProcess
    onExited: function(exitCode) {
      if (exitCode !== 0) root.showError()
    }
  }

  WidgetButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: root.iconText
    fontFamily: "omarchy"
    horizontalMargin: 7.5
    tooltipText: "Current mode: " + root.activeMode.name + " | Version: " + root.pluginVersion
    onPressed: function(mouseButton) {
      if (mouseButton === Qt.LeftButton) root.popupOpen = !root.popupOpen
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
      implicitWidth: Style.space(280)
      implicitHeight: content.implicitHeight + Style.space(24)
      color: "#202020"
      border.color: "#666666"
      border.width: 1
      radius: Style.cornerRadius

      anchors.top: root.bar && root.bar.position === "top" ? parent.top : undefined
      anchors.bottom: root.bar && root.bar.position === "bottom" ? parent.bottom : undefined
      anchors.left: root.bar && root.bar.position === "left" ? parent.left : undefined
      anchors.right: root.bar && root.bar.position === "right" ? parent.right : undefined
      anchors.horizontalCenter: root.bar && (root.bar.position === "top" || root.bar.position === "bottom") ? parent.horizontalCenter : undefined
      anchors.verticalCenter: root.bar && (root.bar.position === "left" || root.bar.position === "right") ? parent.verticalCenter : undefined
      anchors.topMargin: root.bar && root.bar.position === "top" ? root.bar.barSize + 8 : 0
      anchors.bottomMargin: root.bar && root.bar.position === "bottom" ? root.bar.barSize + 8 : 0
      anchors.leftMargin: root.bar && root.bar.position === "left" ? root.bar.barSize + 8 : 0
      anchors.rightMargin: root.bar && root.bar.position === "right" ? root.bar.barSize + 8 : 0

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

        Toggle {
          width: content.width
          label: "Persist"
          description: "Save the selected mode to Hyprland configuration files."
          foreground: "#ffffff"
          fontFamily: root.bar ? root.bar.fontFamily : Style.font.family
          checked: root.persistEnabled
          onClicked: {
            root.persistEnabled = !root.persistEnabled
            if (root.persistEnabled) root.persistMode(root.currentMode)
          }
        }

      }
    }
  }
}
