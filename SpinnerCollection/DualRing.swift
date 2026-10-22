//
//  DualRing.swift
//  SpinnerCollection
//

import SwiftUI

/// Two pairs of arcs on concentric rings, spinning in opposite directions
/// and gently breathing in length.
struct DualRing: View {
    var color: Color = SpinnerPalette.cyan
    /// Seconds per revolution of the outer ring.
    var period: Double = 1.4
    var lineWidth: CGFloat = 0.075

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let stroke = side * lineWidth
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let outerRadius = (side - stroke) / 2
                let innerRadius = outerRadius * 0.62

                let spin = SpinnerMath.frac(t / period) * 360
                let breathe = sin(t / period * 2 * .pi)

                func drawPair(radius: CGFloat, rotation: Double, sweep: Double, color: Color) {
                    for k in 0..<2 {
                        let start = rotation + Double(k) * 180 - sweep / 2
                        var arc = Path()
                        arc.addArc(center: center, radius: radius,
                                   startAngle: .degrees(start),
                                   endAngle: .degrees(start + sweep),
                                   clockwise: false)
                        ctx.stroke(arc, with: .color(color),
                                   style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                    }
                }

                drawPair(radius: outerRadius, rotation: spin,
                         sweep: 95 + 25 * breathe, color: color)
                drawPair(radius: innerRadius, rotation: -spin * 1.3 + 90,
                         sweep: 75 - 20 * breathe, color: color.opacity(0.45))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("DualRing") {
    SpinnerPreviewStage(name: "DualRing") {
        DualRing().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            DualRing(color: .pink, period: 1.0).frame(width: 36, height: 36)
            DualRing(color: .mint, lineWidth: 0.05).frame(width: 36, height: 36)
        }
    }
}
