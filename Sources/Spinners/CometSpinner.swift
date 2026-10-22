//
//  CometSpinner.swift
//  Spinners
//

import SwiftUI

/// A bright head with a long tail that fades to nothing, circling clockwise.
public struct CometSpinner: View {
    var color: Color = SpinnerPalette.teal
    /// Seconds per revolution.
    var period: Double = 1.1
    /// Tail length in degrees.
    var tailLength: Double = 280
    /// Stroke thickness as a fraction of the view's size.
    var lineWidth: CGFloat = 0.09


    public init(
        color: Color = SpinnerPalette.teal,
        period: Double = 1.1,
        tailLength: Double = 280,
        lineWidth: CGFloat = 0.09
    ) {
        self.color = color
        self.period = period
        self.tailLength = tailLength
        self.lineWidth = lineWidth
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let stroke = side * lineWidth
                let radius = (side - stroke * 1.4) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                // Screen angles: 0° = 3 o'clock, increasing clockwise.
                let head = SpinnerMath.frac(t / period) * 360 - 90
                let tail = head - tailLength

                // Tail: short arc segments that fade from transparent to solid.
                let segments = 60
                let step = tailLength / Double(segments)
                for i in 0..<segments {
                    let start = tail + Double(i) * step
                    let fade = Double(i + 1) / Double(segments)
                    var arc = Path()
                    arc.addArc(center: center, radius: radius,
                               startAngle: .degrees(start), endAngle: .degrees(start + step + 0.5),
                               clockwise: false)
                    ctx.stroke(arc, with: .color(color.opacity(fade * fade)),
                               style: StrokeStyle(lineWidth: stroke, lineCap: .butt))
                }

                // The comet's head.
                let rad = head * .pi / 180
                let headPoint = CGPoint(x: center.x + cos(rad) * radius,
                                        y: center.y + sin(rad) * radius)
                let d = stroke * 1.35
                ctx.fill(Path(ellipseIn: CGRect(x: headPoint.x - d / 2, y: headPoint.y - d / 2,
                                                width: d, height: d)),
                         with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("CometSpinner") {
    SpinnerPreviewStage(name: "CometSpinner") {
        CometSpinner().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            CometSpinner(color: .pink, period: 0.8).frame(width: 36, height: 36)
            CometSpinner(color: .orange, tailLength: 180).frame(width: 36, height: 36)
        }
    }
}
