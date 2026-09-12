import QtQuick
import Quickshell
import "../theme"

// Compact status row: clock and authored battery gauge. Content stays glued
// to the screen edge while the silhouette grows around it; content-aware
// layout comes later with the responsive island.
Row {
  id: root

  required property var clock
  required property int batteryPercent
  required property bool hasBattery
  required property bool charging
  required property real revealProgress
  required property bool osdActive
  required property real fontScale

  anchors.horizontalCenter: parent.horizontalCenter
  anchors.top: parent.top
  // Approximate the old vertical centering at the resting height.
  anchors.topMargin: Math.max(0, (Theme.islandHeight - implicitHeight) / 2 - 1)
  spacing: Theme.contentGap
  // Font growth rides on a GPU scale transform, not pixelSize: no text
  // re-rasterization or layout passes during the spring, so it stays smooth.
  scale: fontScale
  transformOrigin: Item.Top
  opacity: Math.max(0, Math.min(1, (revealProgress - 0.34) / 0.66))
    * (osdActive ? 0 : 1)
  visible: opacity > 0

  Behavior on opacity {
    NumberAnimation { duration: 120 }
  }
  transform: Translate {
    y: -root.height * (1 - root.revealProgress)
  }

  Text {
    width: 72
    horizontalAlignment: Text.AlignRight
    text: Qt.formatTime(root.clock.date, "h:mm AP")
    color: Theme.fg
    font.family: Theme.fontUi
    font.pixelSize: 12
    font.weight: Font.Medium
  }

  Rectangle {
    visible: root.hasBattery
    width: 1
    height: 13
    anchors.verticalCenter: parent.verticalCenter
    color: Theme.batteryTrack
  }

  Row {
    visible: root.hasBattery
    width: 63
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    Item {
      width: 20
      height: 10
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        width: 17
        height: 10
        radius: 3
        color: "transparent"
        border.width: 1
        border.color: root.charging ? Theme.green : Theme.fgDim

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.margins: 2
          width: Math.max(2, (parent.width - 4) * root.batteryPercent / 100)
          radius: 1
          color: root.charging ? Theme.green : Theme.fgDim
        }
      }

      Rectangle {
        width: 2
        height: 4
        radius: 1
        anchors.left: parent.left
        anchors.leftMargin: 18
        anchors.verticalCenter: parent.verticalCenter
        color: root.charging ? Theme.green : Theme.fgDim
      }
    }

    Text {
      width: 35
      horizontalAlignment: Text.AlignLeft
      text: root.batteryPercent + "%"
      color: root.charging ? Theme.green : Theme.fgDim
      font.family: Theme.fontUi
      font.pixelSize: 11
    }
  }
}