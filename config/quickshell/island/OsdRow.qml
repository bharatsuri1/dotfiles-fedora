import QtQuick
import "../theme"

// Transient OSD row: icon + slider + percent, same top-edge glue as the
// status row. Volume and brightness share it through showOsd() on the owning
// island; the island's dwell timer returns it to idle.
Row {
  id: root

  required property string osdKind
  required property real osdValue
  required property bool osdMuted
  required property bool osdActive

  anchors.horizontalCenter: parent.horizontalCenter
  anchors.top: parent.top
  anchors.topMargin: Math.max(0, (Theme.islandHeight - implicitHeight) / 2 - 1)
  spacing: Theme.osdContentGap
  transformOrigin: Item.Top

  visible: root.osdActive || opacity > 0
  opacity: root.osdActive ? 1 : 0

  Behavior on opacity {
    NumberAnimation { duration: 120 }
  }

  Text {
    anchors.verticalCenter: parent.verticalCenter
    text: root.osdKind === "brightness"
      ? "\uf522" // brightness
      : root.osdMuted ? "\ueee8" : "\uf028" // mute / volume
    color: root.osdMuted ? Theme.fgDim : Theme.fg
    font.family: Theme.fontIcons
    font.pixelSize: 15
  }

  // Display-only slider: track + proportional fill. Interactive drag is
  // deferred; niri/wpctl remain the source of truth for the value.
  Rectangle {
    id: osdTrack
    width: Theme.osdSliderWidth
    height: Theme.osdTrackHeight
    radius: height / 2
    anchors.verticalCenter: parent.verticalCenter
    color: Theme.batteryTrack

    Rectangle {
      anchors.left: parent.left
      anchors.top: parent.top
      anchors.bottom: parent.bottom
      width: Math.max(0, Math.min(parent.width,
        parent.width * (root.osdMuted ? 0 : root.osdValue)))
      radius: parent.radius
      color: root.osdMuted ? Theme.fgDim : Theme.fg

      Behavior on width {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
      }
    }
  }

  // Fixed slot so percent changes never resize the pill.
  Text {
    width: 38
    horizontalAlignment: Text.AlignLeft
    anchors.verticalCenter: parent.verticalCenter
    text: (root.osdMuted ? 0 : Math.round(root.osdValue * 100)) + "%"
    color: root.osdMuted ? Theme.fgDim : Theme.fg
    font.family: Theme.fontUi
    font.pixelSize: 11
    font.weight: Font.Medium
  }
}