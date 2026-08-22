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

  implicitWidth: morphWidth
  implicitHeight: morphHeight

  // Hover morph. morphWidth/morphHeight are the single animated source of
  // truth: the Shape silhouette and the window input mask both bind to the
  // live size, so the alcove curve re-tessellates every spring frame.
  property bool hovered: false
  property real morphWidth: hovered
    ? Theme.islandWidth * Theme.islandHoverScaleW
    : Theme.islandWidth
  property real morphHeight: hovered
    ? Theme.islandHeight * Theme.islandHoverScaleH
    : Theme.islandHeight

  property real fontScale: hovered ? Theme.islandHoverFontScale : 1.0

  // 0 at resting size, 1 when fully expanded; drives control-button reveal.
  readonly property real expandProgress: {
    const span = Theme.islandHeight * (Theme.islandHoverScaleH - 1)
    return Math.max(0, Math.min(1, (morphHeight - Theme.islandHeight) / span))
  }

  Behavior on morphWidth {
    SpringAnimation { spring: Theme.expandSpring; damping: Theme.expandDamping }
  }
  Behavior on morphHeight {
    SpringAnimation { spring: Theme.expandSpring; damping: Theme.expandDamping }
  }
  Behavior on fontScale {
    SpringAnimation { spring: Theme.expandSpring; damping: Theme.expandDamping }
  }

  HoverHandler {
    onHoveredChanged: root.hovered = hovered
  }

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
        y: root.height - Theme.cornerRadius
      }
      PathCubic {
        x: Theme.topFlareWidth + Theme.cornerRadius
        y: root.height
        control1X: Theme.topFlareWidth
        control1Y: root.height - Theme.cornerRadius * 0.35
        control2X: Theme.topFlareWidth + Theme.cornerRadius * 0.35
        control2Y: root.height
      }
      PathLine {
        x: root.width - Theme.topFlareWidth - Theme.cornerRadius
        y: root.height
      }
      PathCubic {
        x: root.width - Theme.topFlareWidth
        y: root.height - Theme.cornerRadius
        control1X: root.width - Theme.topFlareWidth - Theme.cornerRadius * 0.35
        control1Y: root.height
        control2X: root.width - Theme.topFlareWidth
        control2Y: root.height - Theme.cornerRadius * 0.35
      }
      PathLine {
        x: root.width - Theme.topFlareWidth
        y: Theme.topFlareDepth
      }
      PathCubic {
        x: root.width
        y: 0
        control1X: root.width - Theme.topFlareWidth
        control1Y: Theme.topFlareDepth * 0.45
        control2X: root.width - Theme.topFlareWidth * 0.7
        control2Y: 0
      }
      PathLine { x: 0; y: 0 }
    }
  }

  // Content stays glued to the screen edge while the silhouette grows around
  // it; content-aware layout comes later with the responsive island.
  Row {
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    // Approximate the old vertical centering at the resting height.
    anchors.topMargin: Math.max(0, (Theme.islandHeight - implicitHeight) / 2 - 1)
    spacing: Theme.contentGap
    // Font growth rides on a GPU scale transform, not pixelSize: no text
    // re-rasterization or layout passes during the spring, so it stays smooth.
    scale: root.fontScale
    transformOrigin: Item.Top
    opacity: Math.max(0, Math.min(1, (root.revealProgress - 0.34) / 0.66))
    transform: Translate {
      y: -root.height * (1 - root.revealProgress)
    }

    Text {
      width: 72
      horizontalAlignment: Text.AlignRight
      text: Qt.formatTime(clock.date, "h:mm AP")
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

  // Control buttons: revealed inside the expanded silhouette. They fade and
  // settle with the same spring progress that drives the shape morph.
  Row {
    id: controls
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Theme.islandHeight + 10
    spacing: Theme.controlGap

    visible: root.expandProgress > 0.05
    opacity: root.expandProgress
    scale: 0.85 + 0.15 * root.expandProgress
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
}
