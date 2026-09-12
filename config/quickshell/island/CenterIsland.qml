import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import "../theme"

// MVP surface: state machine, event-driven providers, and composition of the
// alcove's content rows. The silhouette lives in IslandShape; content lives
// in StatusRow, OsdRow, and ControlsRow.
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

  // --- real volume source: default PipeWire sink ---
  // niri/wpctl remain the writers; the island only observes. PwNodeTracker
  // is required for property change signals to fire on the node.
  readonly property PwNode defaultSink: Pipewire.defaultAudioSink
  readonly property var sinkAudio: defaultSink ? defaultSink.audio : null

  // Suppress OSD flashes while the bindings populate on shell start.
  property bool audioReady: false
  property bool brightnessReady: false
  Timer {
    running: true
    interval: 2000
    onTriggered: {
      root.audioReady = true
      root.brightnessReady = true
    }
  }

  PwObjectTracker {
    objects: root.defaultSink ? [root.defaultSink] : []
  }

  Connections {
    target: root.sinkAudio
    function onVolumesChanged() { root.onSinkEvent() }
    function onMutedChanged() { root.onSinkEvent() }
  }

  function onSinkEvent() {
    if (!audioReady || !sinkAudio)
      return
    showOsd("volume", sinkAudio.volume, sinkAudio.muted)
  }

  // --- real brightness source: sysfs backlight ---
  // Quickshell 0.2.1 has no backlight service, so the island watches the
  // sysfs brightness file. watchChanges is inotify-based: event-driven,
  // zero polling (verified: the kernel emits fsnotify MODIFY on this file).
  // brightnessctl remains the writer via niri keybinds; display-only.
  FileView {
    id: brightnessFile
    path: "/sys/class/backlight/" + Theme.backlightDevice + "/brightness"
    preload: true
    watchChanges: true
    onFileChanged: reload()
    onTextChanged: root.onBrightnessEvent()
  }

  // Static for the device's lifetime: read once, no watcher.
  FileView {
    id: maxBrightnessFile
    path: "/sys/class/backlight/" + Theme.backlightDevice + "/max_brightness"
    preload: true
  }

  function onBrightnessEvent() {
    if (!brightnessReady || !brightnessFile.loaded || !maxBrightnessFile.loaded)
      return
    const max = parseFloat(maxBrightnessFile.text())
    if (!(max > 0))
      return
    showOsd("brightness", parseFloat(brightnessFile.text()) / max, false)
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

  // Fade factor for the control row, derived from the silhouette's live
  // bottom edge instead of raw expand progress: 1 only once the edge is
  // clear of the row by controlFadeSpan, 0 as soon as the edge starts to
  // retreat below the row's bottom. This keeps icons from ever painting
  // outside the collapsed panel (see ControlsRow).
  readonly property real controlEdgeProgress: {
    const rowBottom = Theme.islandHeight + Theme.controlTopGap + Theme.controlSize
    return Math.max(0, Math.min(1,
      (morphHeight - rowBottom) / Theme.controlFadeSpan))
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

  IslandShape {
    revealProgress: root.revealProgress
  }

  StatusRow {
    clock: clock
    batteryPercent: root.batteryPercent
    hasBattery: root.hasBattery
    charging: root.charging
    revealProgress: root.revealProgress
    osdActive: root.osdActive
    fontScale: root.fontScale
  }

  OsdRow {
    osdKind: root.osdKind
    osdValue: root.osdValue
    osdMuted: root.osdMuted
    osdActive: root.osdActive
  }

  ControlsRow {
    edgeProgress: root.controlEdgeProgress
    osdActive: root.osdActive
  }
}