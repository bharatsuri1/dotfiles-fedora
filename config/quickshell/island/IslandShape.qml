import QtQuick
import QtQuick.Shapes
import "../theme"

// The alcove silhouette: flush sidewalls grow directly from the screen edge,
// then settle into generous lower corners. Drawn as a filled Shape so the
// curve re-tessellates every frame while the owning island animates its size.
// revealProgress drives the top-edge entrance; the owning island supplies it.
Shape {
  required property real revealProgress

  anchors.fill: parent
  opacity: revealProgress
  transform: Translate {
    y: -height * (1 - revealProgress)
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
      y: height - Theme.cornerRadius
    }
    PathCubic {
      x: Theme.topFlareWidth + Theme.cornerRadius
      y: height
      control1X: Theme.topFlareWidth
      control1Y: height - Theme.cornerRadius * 0.35
      control2X: Theme.topFlareWidth + Theme.cornerRadius * 0.35
      control2Y: height
    }
    PathLine {
      x: width - Theme.topFlareWidth - Theme.cornerRadius
      y: height
    }
    PathCubic {
      x: width - Theme.topFlareWidth
      y: height - Theme.cornerRadius
      control1X: width - Theme.topFlareWidth - Theme.cornerRadius * 0.35
      control1Y: height
      control2X: width - Theme.topFlareWidth
      control2Y: height - Theme.cornerRadius * 0.35
    }
    PathLine {
      x: width - Theme.topFlareWidth
      y: Theme.topFlareDepth
    }
    PathCubic {
      x: width
      y: 0
      control1X: width - Theme.topFlareWidth
      control1Y: Theme.topFlareDepth * 0.45
      control2X: width - Theme.topFlareWidth * 0.7
      control2Y: 0
    }
    PathLine { x: 0; y: 0 }
  }
}