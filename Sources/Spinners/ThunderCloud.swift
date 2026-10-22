//
//  ThunderCloud.swift
//  Spinners
//

import SwiftUI

/// A rain cloud with steady slanted rain and a double-flicker of lightning.
public struct ThunderCloud: View {
    var color: Color = SpinnerPalette.cyan
    /// Seconds between lightning strikes.
    var strikeInterval: Double = 2.4


    public init(
        color: Color = SpinnerPalette.cyan,
        strikeInterval: Double = 2.4
    ) {
        self.color = color
        self.strikeInterval = strikeInterval
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self
                let cycle = M.frac(t / strikeInterval)
                let flash = cycle < 0.06 || (cycle > 0.1 && cycle < 0.14)

                // Rain.
                for i in 0..<14 {
                    let d = Double(i)
                    let p = M.frac(t * 1.4 + M.rnd(d))
                    let x = 34 + M.rnd(d + 9) * 72 - p * 8
                    let y = 66 + p * 60
                    var drop = Path()
                    drop.move(to: CGPoint(x: x, y: y))
                    drop.addLine(to: CGPoint(x: x - 3, y: y + 9))
                    ctx.stroke(drop, with: .color(color.opacity(0.7 * (1 - p))),
                               style: StrokeStyle(lineWidth: 2, lineCap: .round))
                }

                // Lightning bolt.
                if flash {
                    let points: [CGPoint] = [
                        CGPoint(x: 74, y: 58), CGPoint(x: 62, y: 84), CGPoint(x: 72, y: 84),
                        CGPoint(x: 60, y: 112), CGPoint(x: 84, y: 78), CGPoint(x: 74, y: 78),
                        CGPoint(x: 82, y: 58),
                    ]
                    var bolt = Path()
                    bolt.addLines(points)
                    bolt.closeSubpath()
                    ctx.fill(bolt, with: .color(color))
                }

                // Cloud: overlapping puffs drawn as one layer so the overlaps don't double up.
                var cloud = ctx
                cloud.opacity = flash ? 0.95 : 0.6
                cloud.drawLayer { layer in
                    let puffs: [(CGFloat, CGFloat, CGFloat)] = [
                        (48, 52, 16), (68, 40, 22), (92, 50, 18), (104, 58, 12), (36, 60, 11),
                    ]
                    for (x, y, r) in puffs {
                        layer.fill(.circle(CGPoint(x: x, y: y), r), with: .color(color))
                    }
                    layer.fill(Path(CGRect(x: 36, y: 52, width: 68, height: 18)), with: .color(color))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("ThunderCloud") {
    SpinnerPreviewStage(name: "ThunderCloud") {
        ThunderCloud().frame(width: 120, height: 120)
        HStack(spacing: 32) {
            ThunderCloud(color: .purple, strikeInterval: 1.5).frame(width: 44, height: 44)
            ThunderCloud(color: .yellow).frame(width: 44, height: 44)
        }
    }
}
