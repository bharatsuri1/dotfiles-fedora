pragma Singleton

import QtQuick

// Vesper design tokens for the desktop shell. The palette mirrors
// config/alacritty/themes/vesper.toml so every surface on the machine
// shares one source of truth.
QtObject {
  // --- palette (Vesper) ---
  readonly property color bg: "#101010"
  readonly property color fg: "#ffffff"
  readonly property color fgDim: "#a0a0a0"
  readonly property color accent: "#ffc799"
  readonly property color green: "#90b99f"
  readonly property color batteryTrack: "#30ffffff"

  // --- typography ---
  readonly property string fontUi: "Inter"
  readonly property string fontIcons: "JetBrainsMono Nerd Font"

  // --- island geometry ---
  readonly property int islandWidth: 250
  readonly property int islandHeight: 34
  readonly property int topFlareWidth: 4
  readonly property int topFlareDepth: 8
  readonly property int cornerRadius: 15
  readonly property int contentGap: 14

  // --- motion ---
  // The MVP has one authored moment: the alcove settles in from the screen
  // edge when the shell starts. Disable this switch for an immediate render.
  readonly property bool motionEnabled: true
  readonly property int revealDuration: 360

  // --- hover morph ---
  // While hovered the island springs to a larger silhouette. The spring is a
  // real physics animation (SpringAnimation): stiffness controls snap, damping
  // controls how quickly the overshoot settles. Lower damping = bouncier.
  readonly property real islandHoverScaleW: 1.4
  readonly property real islandHoverScaleH: 3.0
  readonly property real islandHoverFontScale: 1.5
  readonly property real expandSpring: 4.0
  readonly property real expandDamping: 0.4

  // --- control buttons (shown while the island is expanded) ---
  readonly property int controlSize: 34
  readonly property int controlGap: 18
  readonly property color controlBg: "#262626"
  // Hover washes the button in warm orange and flips the glyph to the
  // background color so it stays readable.
  readonly property color controlBgHover: accent
  readonly property color controlFg: fg
  readonly property color controlFgHover: bg
}
