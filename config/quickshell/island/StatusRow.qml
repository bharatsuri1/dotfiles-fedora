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
  // Type and gauge grow gently on hover via the GPU scale transform: smooth
  // at any speed, and at this small factor (1.12x) text softening is
  // imperceptible against the spring motion.
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
    font.pixelSize: 12
    width: 72
    horizontalAlignment: Text.AlignRight
    text: Qt.formatTime(root.clock.date, "h:mm AP")
    color: Theme.fg
    font.family: Theme.fontUi
    font.weight: Font.Medium
  }

  Rectangle {
    visible: root.hasBattery
    width: 1
    // Slightly shorter than the clock's cap height so it reads as
    // punctuation between time and battery, not a glitch bar.
    height: 10
    anchors.verticalCenter: parent.verticalCenter
    color: Theme.batteryTrack
  }

  Row {
    visible: root.hasBattery
    width: 61
    spacing: 8
    anchors.verticalCenter: parent.verticalCenter

    Item {
      // Gauge spans 18px: 16px body + 2px nub fused to its edge. All even
      // dimensions stay pixel-snapped at 1.5x display scale and the 1.12x
      // hover font scale, so the outline stays crisp beside the type.
      width: 18
      height: 10
      anchors.verticalCenter: parent.verticalCenter

      Rectangle {
        width: 16
        height: 10
        radius: 2
        color: "transparent"
        border.width: 1
        // Charging hues only the fill and percent text; the gauge's casing
        // stays dim so "energy filling" reads, not "battery turned green".
        border.color: Theme.fgDim

        Rectangle {
          anchors.left: parent.left
          anchors.top: parent.top
          anchors.bottom: parent.bottom
          anchors.margins: 2
          // Honest at the low end: exact fill below 6%, so 0%, 3%, and 13%
          // all paint differently; the 2px floor keeps 6%+ visually present.
          width: root.batteryPercent > 5
            ? Math.max(2, (parent.width - 4) * root.batteryPercent / 100)
            : (parent.width - 4) * root.batteryPercent / 100
          radius: 1
          color: root.charging ? Theme.green : Theme.fgDim
        }
      }

      Rectangle {
        width: 2
        height: 4
        radius: 1
        anchors.left: parent.left
        // Fused to the gauge body like a real battery terminal, not a dot.
        anchors.leftMargin: 16
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.fgDim
      }
    }

    Text {
      font.pixelSize: 11
      width: 35
      horizontalAlignment: Text.AlignLeft
      text: root.batteryPercent + "%"
      color: root.charging ? Theme.green : Theme.fgDim
      font.family: Theme.fontUi
    }
  }
}
