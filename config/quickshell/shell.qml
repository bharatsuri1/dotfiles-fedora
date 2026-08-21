// Vesper Quickshell shell
//
// THESIS: one calm, top-edge alcove carries only the information that earns a
// permanent place: time and battery. It refuses the density of a conventional
// status bar.
// OWN-WORLD: opaque Vesper black, quiet white type, measured spacing, and a
// top-flush silhouette with clean sidewalls and soft lower corners.
// STORY: glance at the center edge, read time and remaining power, return to
// the task without interacting with chrome.
// FIRST VIEWPORT: a compact centered island begins flush with the top edge on
// each output; the rest of the transparent strip is empty and click-through.
// FORM: approved static alcove with one restrained top-edge entrance; no
// looping, reactive, hover, or state motion is part of the MVP.
// FINISH: unreviewed and undocumented is unfinished; this build ends with the
// finish review, the verdict, and DESIGN.md.
//
// Run with: `quickshell` (loads ~/.config/quickshell/shell.qml by default) or
// `quickshell -p <path>`. Quickshell hot-reloads this tree on save.

import Quickshell
import "island"
import "theme"

ShellRoot {
  id: root

  // One strip per connected screen. Variants rebuilds the delegate whenever
  // the screen set changes, so hotplugging and niri output changes are
  // handled without a manual restart.
  Variants {
    model: Quickshell.screens

    delegate: PanelWindow {
      id: strip
      property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      // The surface is tall enough for the hovered island to draw fully, but
      // only the resting height is reserved on the screen. The overhang is
      // transparent and click-through via the island-shaped input mask.
      implicitHeight: Theme.islandHeight * Theme.islandHoverScaleH
      exclusiveZone: Theme.islandHeight
      exclusionMode: ExclusionMode.Normal
      aboveWindows: true

      visible: true
      color: "transparent"

      // The empty strip never steals pointer input from windows below it.
      mask: Region { item: island }

      CenterIsland {
        id: island
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
      }
    }
  }
}
