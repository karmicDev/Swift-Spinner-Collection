//
//  PancakeBatter.swift
//  Spinners
//

import SwiftUI

/// A whisk circling through a bowl of batter: the batter swirls, the whisk passes
/// behind and in front of the rim, and a few drops splash out.
public struct PancakeBatter: View {
    var color: Color = SpinnerPalette.amber
    /// Seconds per whisk revolution.
    var period: Double = 2.1


    public init(
        color: Color = SpinnerPalette.amber,
        period: Double = 2.1
    ) {
        self.color = color
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self
                let cx = 70.0, cy = 86.0
                let speed = 2 * Double.pi / period
                let round = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

                // Batter surface with two swirls.
                ctx.fill(.ellipse(CGPoint(x: cx, y: cy), 40, 10), with: .color(color.opacity(0.4)))
                for k in 0..<2 {
                    var swirl = Path()
                    for i in 0...40 {
                        let a = Double(i) / 40 * .pi * 1.4 + t * speed + Double(k) * .pi
                        let r = 6 + Double(i) * 0.75
                        let p = CGPoint(x: cx + cos(a) * r, y: cy + sin(a) * r * 0.25)
                        if i == 0 { swirl.move(to: p) } else { swirl.addLine(to: p) }
                    }
                    ctx.stroke(swirl, with: .color(color.opacity(0.75)), lineWidth: 1.5)
                }

                // Whisk position on its circle; behind the rim for half of each turn.
                let angle = t * speed
                let wx = cx + cos(angle) * 16, wy = cy + sin(angle) * 4
                let tilt = cos(angle) * 0.25
                let behind = sin(angle) < 0

                func drawWhisk() {
                    var w = ctx
                    w.translateBy(x: wx, y: wy)
                    w.rotate(by: .radians(tilt))
                    var handle = Path()
                    handle.move(to: CGPoint(x: 0, y: -14))
                    handle.addLine(to: CGPoint(x: 0, y: -58))
                    w.stroke(handle, with: .color(color), style: round)
                    for (width, alpha) in [(11.0, 1.0), (6.0, 0.75), (2.5, 0.5)] {
                        var wire = Path()
                        wire.move(to: CGPoint(x: -3, y: -16))
                        wire.addCurve(to: CGPoint(x: 0, y: 6),
                                      control1: CGPoint(x: -width - 2, y: -10),
                                      control2: CGPoint(x: -width, y: 4))
                        wire.addCurve(to: CGPoint(x: 3, y: -16),
                                      control1: CGPoint(x: width, y: 4),
                                      control2: CGPoint(x: width + 2, y: -10))
                        w.stroke(wire, with: .color(color.opacity(min(alpha + 0.25, 1))), lineWidth: 1.8)
                    }
                }

                if behind { drawWhisk() }

                // Bowl.
                var bowl = Path()
                bowl.move(to: CGPoint(x: 26, y: 84))
                bowl.addCurve(to: CGPoint(x: 114, y: 84),
                              control1: CGPoint(x: 28, y: 122), control2: CGPoint(x: 112, y: 122))
                bowl.move(to: CGPoint(x: 24, y: 84))
                bowl.addLine(to: CGPoint(x: 116, y: 84))
                ctx.stroke(bowl, with: .color(color), style: round)

                if !behind { drawWhisk() }

                // Splashing drops.
                for i in 0..<3 {
                    let d = Double(i)
                    let phase = t * 1.5 + d / 3
                    let p = M.frac(phase)
                    let dir: Double = M.rnd(d + phase.rounded(.down)) > 0.5 ? 1 : -1
                    let drop = CGPoint(x: wx + dir * p * 20, y: 78 - sin(p * .pi) * 22)
                    ctx.fill(.circle(drop, 2.2), with: .color(color.opacity(0.8 * (1 - p))))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("PancakeBatter") {
    SpinnerPreviewStage(name: "PancakeBatter") {
        PancakeBatter().frame(width: 120, height: 120)
        HStack(spacing: 32) {
            PancakeBatter(color: .pink, period: 1.2).frame(width: 44, height: 44)
            PancakeBatter(color: .cyan).frame(width: 44, height: 44)
        }
    }
}
