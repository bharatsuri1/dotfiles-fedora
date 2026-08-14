// Vesper Quickshell shell
//
// Repository-owned desktop shell for the bare-niri session. This entry point
// is intentionally minimal: it renders one top bar per screen so the
// Quickshell process, niri layer-shell integration, and systemd lifecycle can
// be validated before the launcher and the macOS-style alcove land in Ticket 7.
//
// Run with: `quickshell` (loads ~/.config/quickshell/shell.qml by default) or
// `quickshell -p <path>`. Quickshell hot-reloads this file on save.

import QtQuick
import Quickshell

ShellRoot {
  id: root

  // One top bar per connected screen. Variants rebuilds the delegate whenever
  // the screen set changes, so hotplugging and niri output changes are handled
  // without a manual restart.
  Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
      id: bar
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }
      // Reserve space so tiling windows never render under the bar. Use
      // implicitHeight (PanelWindow deprecates `height`) and bind the
      // exclusiveZone to it so the reserved strip matches the bar height.
      implicitHeight: 32
      exclusiveZone: bar.implicitHeight
      exclusionMode: ExclusionMode.Normal
      aboveWindows: true

      visible: true
      color: "#101010"

      // Zero-polling clock: SystemClock emits a fresh `date` per precision.
      SystemClock {
        id: clock
        precision: SystemClock.Seconds
        enabled: true
      }

      Text {
        anchors.left: parent.left
        anchors.leftMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        text: "niri"
        color: "#ffc799"
        font.family: "Noto Sans"
        font.weight: Font.Bold
        font.pixelSize: 13
      }

      Text {
        anchors.centerIn: parent
        color: "#ffffff"
        font.family: "Noto Sans"
        font.pixelSize: 13
        text: Qt.formatDateTime(clock.date, "ddd  yyyy-MM-dd  HH:mm:ss")
      }

      Text {
        anchors.right: parent.right
        anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter
        color: "#9a9a9a"
        font.family: "Noto Sans"
        font.pixelSize: 13
        text: bar.screen ? bar.screen.name : ""
      }
    }
  }
}