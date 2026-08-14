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
  readonly property string fontUi: "Noto Sans"
  readonly property string fontData: "JetBrainsMono Nerd Font"

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
}
