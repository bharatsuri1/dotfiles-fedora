import QtQuick
import Quickshell
import "../theme"

// Control buttons: revealed inside the expanded silhouette. Visibility is
// derived from the silhouette's live bottom edge (edgeProgress), not raw
// expand progress: the icons fade to zero exactly as the collapsing edge
// crosses the row's bottom, so they are never seen floating outside the
// panel. While visible the row rides slightly below the live bottom edge so
// buttons emerge from behind it instead of popping in place.
Row {
  id: root

  required property real edgeProgress
  required property bool osdActive

  // Distance from the top strip to the row; CenterIsland's
  // controlEdgeProgress uses the same constants, so both stay in sync.
  readonly property real rowTop: Theme.islandHeight + Theme.controlTopGap

  anchors.horizontalCenter: parent.horizontalCenter
  anchors.top: parent.top
  anchors.topMargin: root.rowTop

  spacing: Theme.controlGap

  visible: !root.osdActive && root.edgeProgress > 0
  opacity: root.edgeProgress
  scale: 0.85 + 0.15 * root.edgeProgress
  transformOrigin: Item.Top

  Repeater {
    // Each button launches its TUI in a floating Alacritty window; the
    // Island* app-ids match the niri floating rules in config/niri.
    model: [
      { glyph: "\uf1eb", name: "wifi",
        command: ["alacritty", "--class", "IslandWifi", "--title", "Wi-Fi", "-e", "wlctl"] },
      { glyph: "\udb80\udcaf", name: "bluetooth",
        command: ["alacritty", "--class", "IslandBluetooth", "--title", "Bluetooth", "-e", "bluetui"] },
      { glyph: "\uf028", name: "sound",
        command: ["alacritty", "--class", "IslandAudio", "--title", "Audio", "-e", "wiremix", "-v", "playback"] },
      { glyph: "\u23fb", name: "power",
        command: ["alacritty", "--class", "IslandPower", "--title", "Power", "-e", "island-power"] },
      { glyph: "\uf023", name: "lock",
        command: ["lock-screen"] }
    ]

    delegate: Rectangle {
      id: controlButton
      required property var modelData

      property bool buttonHovered: false

      width: Theme.controlSize
      height: Theme.controlSize
      radius: width / 2
      color: buttonHovered ? Theme.controlBgHover : Theme.controlBg

      Behavior on color {
        ColorAnimation { duration: 120 }
      }

      Text {
        anchors.centerIn: parent
        text: controlButton.modelData.glyph
        color: controlButton.buttonHovered
          ? Theme.controlFgHover
          : Theme.controlFg
        font.family: Theme.fontIcons
        font.pixelSize: 16
      }

      HoverHandler {
        onHoveredChanged: controlButton.buttonHovered = hovered
        cursorShape: Qt.PointingHandCursor
      }

      MouseArea {
        anchors.fill: parent
        onClicked: Quickshell.execDetached(controlButton.modelData.command)
      }
    }
  }
}