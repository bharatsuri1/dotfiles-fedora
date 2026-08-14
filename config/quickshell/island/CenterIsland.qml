import QtQuick
import QtQuick.Shapes
import Quickshell
import Quickshell.Services.UPower
import "../theme"

// MVP surface. Its silhouette is authored as an alcove rather than a floating
// pill: flush sidewalls grow directly from the screen edge, then settle into
// generous lower corners.
Item {
  id: root

  implicitWidth: Theme.islandWidth
  implicitHeight: Theme.islandHeight

  property real revealProgress: Theme.motionEnabled ? 0 : 1

  readonly property UPowerDevice battery: UPower.displayDevice
  readonly property bool hasBattery:
    battery !== null && battery.ready && battery.isLaptopBattery
  readonly property int batteryPercent:
    hasBattery ? Math.max(0, Math.min(100, Math.round(battery.percentage * 100))) : 0
  readonly property bool charging:
    hasBattery && battery.state === UPowerDeviceState.Charging

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  NumberAnimation {
    id: entrance
    target: root
    property: "revealProgress"
    from: 0
    to: 1
    duration: Theme.revealDuration
    easing.type: Easing.OutExpo
  }

  Component.onCompleted: {
    if (Theme.motionEnabled)
      entrance.restart();
  }

  Shape {
    anchors.fill: parent
    opacity: root.revealProgress
    transform: Translate {
      y: -root.height * (1 - root.revealProgress)
    }
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      fillColor: Theme.bg
      strokeWidth: -1

      startX: 0
      startY: 0
      PathCubic {
        x: Theme.topFlareWidth
        y: Theme.topFlareDepth
        control1X: Theme.topFlareWidth * 0.7
        control1Y: 0
        control2X: Theme.topFlareWidth
        control2Y: Theme.topFlareDepth * 0.45
      }
      PathLine {
        x: Theme.topFlareWidth
        y: Theme.islandHeight - Theme.cornerRadius
      }
      PathCubic {
        x: Theme.topFlareWidth + Theme.cornerRadius
        y: Theme.islandHeight
        control1X: Theme.topFlareWidth
        control1Y: Theme.islandHeight - Theme.cornerRadius * 0.35
        control2X: Theme.topFlareWidth + Theme.cornerRadius * 0.35
        control2Y: Theme.islandHeight
      }
      PathLine {
        x: Theme.islandWidth - Theme.topFlareWidth - Theme.cornerRadius
        y: Theme.islandHeight
      }
      PathCubic {
        x: Theme.islandWidth - Theme.topFlareWidth
        y: Theme.islandHeight - Theme.cornerRadius
        control1X: Theme.islandWidth - Theme.topFlareWidth - Theme.cornerRadius * 0.35
        control1Y: Theme.islandHeight
        control2X: Theme.islandWidth - Theme.topFlareWidth
        control2Y: Theme.islandHeight - Theme.cornerRadius * 0.35
      }
      PathLine {
        x: Theme.islandWidth - Theme.topFlareWidth
        y: Theme.topFlareDepth
      }
      PathCubic {
        x: Theme.islandWidth
        y: 0
        control1X: Theme.islandWidth - Theme.topFlareWidth
        control1Y: Theme.topFlareDepth * 0.45
        control2X: Theme.islandWidth - Theme.topFlareWidth * 0.7
        control2Y: 0
      }
      PathLine { x: 0; y: 0 }
    }
  }

  Row {
    anchors.centerIn: parent
    anchors.verticalCenterOffset: -1
    spacing: Theme.contentGap
    opacity: Math.max(0, Math.min(1, (root.revealProgress - 0.34) / 0.66))
    transform: Translate {
      y: -root.height * (1 - root.revealProgress)
    }

    Text {
      width: 72
      horizontalAlignment: Text.AlignRight
      text: Qt.formatTime(clock.date, "h:mm AP")
      color: Theme.fg
      font.family: Theme.fontData
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
        font.family: Theme.fontData
        font.pixelSize: 11
      }
    }
  }
}
