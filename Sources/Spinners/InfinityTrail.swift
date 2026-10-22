//
//  InfinityTrail.swift
//  Spinners
//

import SwiftUI

/// A tapered comet racing around a faint figure-eight track.
public struct InfinityTrail: View {
    var color: Color = SpinnerPalette.pink
    /// Seconds per lap of the figure-eight.
    var period: Double = 2.0
    /// Trail length as a fraction of the lap.
    var trailLength: Double = 0.22


    public init(
        color: Color = SpinnerPalette.pink,
        period: Double = 2.0,
        trailLength: Double = 0.22
    ) {
        self.color = color
        self.period = period
        self.trailLength = trailLength
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let stroke = min(size.width * 0.06, size.height * 0.13)
                let rx = size.width / 2 - stroke
                let ry = (size.height / 2 - stroke) / 0.36
                let c = CGPoint(x: size.width / 2, y: size.height / 2)

                // Lemniscate of Bernoulli.
                func point(_ u: Double) -> CGPoint {
                    let s = sin(u), k = 1 + s * s
                    return CGPoint(x: c.x + rx * cos(u) / k, y: c.y + ry * s * cos(u) / k)
                }

                // Faint track.
                var track = Path()
                let steps = 120
                for i in 0...steps {
                    let p = point(Double(i) / Double(steps) * 2 * .pi)
                    if i == 0 { track.move(to: p) } else { track.addLine(to: p) }
                }
                ctx.stroke(track, with: .color(color.opacity(0.2)), lineWidth: stroke * 0.25)

                // Comet: segments get thicker and brighter toward the head.
                let head = SpinnerMath.frac(t / period) * 2 * .pi
                let span = trailLength * 2 * .pi
                let segments = 36
                for i in 0..<segments {
                    let f0 = Double(i) / Double(segments)
                    let f1 = Double(i + 1) / Double(segments)
                    var seg = Path()
                    seg.move(to: point(head - span * (1 - f0)))
                    seg.addLine(to: point(head - span * (1 - f1)))
                    ctx.stroke(seg, with: .color(color.opacity(f1)),
                               style: StrokeStyle(lineWidth: stroke * (0.2 + 0.8 * f1), lineCap: .round))
                }
            }
        }
        .aspectRatio(2, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("InfinityTrail") {
    SpinnerPreviewStage(name: "InfinityTrail") {
        InfinityTrail().frame(width: 160, height: 80)
        HStack(spacing: 32) {
            InfinityTrail(color: .cyan, period: 1.4).frame(width: 72, height: 36)
            InfinityTrail(color: .orange, trailLength: 0.35).frame(width: 72, height: 36)
        }
    }
}
