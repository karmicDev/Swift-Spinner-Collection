//
//  LiquidFill.swift
//  SpinnerCollection
//

import SwiftUI

/// A round flask that slowly fills and drains, with two rolling waves on the surface.
struct LiquidFill: View {
    var color: Color = SpinnerPalette.pink
    /// Seconds for one fill + drain.
    var fillPeriod: Double = 4.0
    /// Seconds for a wave crest to roll across.
    var wavePeriod: Double = 1.2

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let stroke = side * 0.035
                let outerR = (side - stroke) / 2
                let innerR = outerR - stroke * 1.6

                ctx.stroke(Path(ellipseIn: CGRect(x: c.x - outerR, y: c.y - outerR,
                                                  width: outerR * 2, height: outerR * 2)),
                           with: .color(color.opacity(0.85)), lineWidth: stroke)

                var inside = ctx
                inside.clip(to: Path(ellipseIn: CGRect(x: c.x - innerR, y: c.y - innerR,
                                                       width: innerR * 2, height: innerR * 2)))

                // Fill level from 15% to 85%.
                let level = 0.15 + 0.7 * (0.5 - 0.5 * cos(t / fillPeriod * 2 * .pi))
                let surfaceY = c.y + innerR - CGFloat(level) * innerR * 2
                let amp = innerR * 0.08
                let left = c.x - innerR, right = c.x + innerR, bottom = c.y + innerR

                func wave(phase: Double, opacity: Double) {
                    var path = Path()
                    path.move(to: CGPoint(x: left, y: bottom))
                    let steps = 40
                    for i in 0...steps {
                        let f = Double(i) / Double(steps)
                        let x = left + (right - left) * f
                        let y = surfaceY + amp * sin(f * 2 * .pi * 1.2 + phase)
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    path.addLine(to: CGPoint(x: right, y: bottom))
                    path.closeSubpath()
                    inside.fill(path, with: .color(color.opacity(opacity)))
                }

                let roll = t / wavePeriod * 2 * .pi
                wave(phase: -roll * 0.8 + 1.7, opacity: 0.4)   // back wave
                wave(phase: roll, opacity: 0.85)               // front wave
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("LiquidFill") {
    SpinnerPreviewStage(name: "LiquidFill") {
        LiquidFill().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            LiquidFill(color: .cyan, fillPeriod: 2.5).frame(width: 36, height: 36)
            LiquidFill(color: .mint).frame(width: 36, height: 36)
        }
    }
}
