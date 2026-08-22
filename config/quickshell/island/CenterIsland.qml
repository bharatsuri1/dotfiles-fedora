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
  // Presentation mode. "osd" is a transient modal overlay (volume, later
  // brightness): it wins over hover, hides status + controls, and reuses the
  // same morph primitives so the silhouette and input mask stay correct.
  // "idle"/"hover" are derived from `hovered` when no OSD is active.
  property string mode: "idle" // "idle" | "hover" | "osd"
  property string osdKind: "none" // "none" | "volume" | "brightness"
  property real osdValue: 0 // 0..1
  property bool osdMuted: false

  readonly property bool osdActive: mode === "osd"
  readonly property string effectiveMode:
    osdActive ? "osd" : (hovered ? "hover" : "idle")

  // Single entry point for OSD content (volume now, brightness later).
  // Every call refreshes the value and resets the dwell timer.
  function showOsd(kind, value, muted) {
    root.osdKind = kind
    root.osdValue = Math.max(0, Math.min(1, value))
    root.osdMuted = muted ?? false
    root.mode = "osd"
    osdDwell.restart()
  }

  Timer {
    id: osdDwell
    interval: Theme.osdDwellMs
    onTriggered: root.mode = root.hovered ? "hover" : "idle"
  }

  // Dry-run trigger (no PipeWire yet): while osdDebug is on, step a fake
  // volume up/down so the morph, layout, and dwell can be reviewed live.
  Timer {
    id: osdDebugStepper
    interval: Theme.osdDwellMs + 900 // let the OSD exit between steps
    repeat: true
    running: Theme.osdDebug
    property real step: 0
    onTriggered: {
      step = (step + 1) % 6
      root.showOsd("volume", 0.35 + step * 0.13, step === 4)
    }
  }

  property real morphWidth: root.effectiveMode === "osd"
    ? Theme.islandWidth * Theme.islandOsdScaleW
    : root.hovered
      ? Theme.islandWidth * Theme.islandHoverScaleW
      : Theme.islandWidth
  property real morphHeight: root.effectiveMode === "osd"
    ? Theme.islandHeight * Theme.islandOsdScaleH
    : root.hovered
      ? Theme.islandHeight * Theme.islandHoverScaleH
      : Theme.islandHeight

  property real fontScale:
    root.effectiveMode === "hover" ? Theme.islandHoverFontScale : 1.0

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
      * (root.osdActive ? 0 : 1)
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

  // Transient OSD row: icon + slider + percent, same top-edge glue as the
  // status row. Volume now; brightness reuses this with showOsd().
  Row {
    id: osdRow
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Math.max(0, (Theme.islandHeight - implicitHeight) / 2 - 1)
    spacing: Theme.osdContentGap
    transformOrigin: Item.Top

    visible: root.osdActive || osdRow.opacity > 0
    opacity: root.osdActive ? 1 : 0

    Behavior on opacity {
      NumberAnimation { duration: 120 }
    }

    Text {
      anchors.verticalCenter: parent.verticalCenter
      text: root.osdKind === "brightness"
        ? "\uf5de" // brightness
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

  // Control buttons: revealed inside the expanded silhouette. They fade and
  // settle with the same spring progress that drives the shape morph.
  Row {
    id: controls
    anchors.horizontalCenter: parent.horizontalCenter
    anchors.top: parent.top
    anchors.topMargin: Theme.islandHeight + 10
    spacing: Theme.controlGap

    visible: !root.osdActive && root.expandProgress > 0.05
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
