//
//  MeltingIceCream.swift
//  SpinnerCollection
//

import SwiftUI

/// An ice cream scoop on a waffle cone slowly sags while drips run down the cone
/// and drops fall into a growing puddle. Then a fresh scoop pops back.
struct MeltingIceCream: View {
    var color: Color = SpinnerPalette.pink
    /// Seconds for one melt-and-refill cycle.
    var period: Double = 5.5

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self
                let p = M.frac(t / period)
                let melt = CGFloat(M.ease(p / 0.85))
                let refill: CGFloat = p > 0.88 ? CGFloat((p - 0.88) / 0.12) : 0
                let alpha = Double(1 - refill)
                let cx: CGFloat = 70

                // Waffle cone.
                var cone = Path()
                cone.addLines([CGPoint(x: 48, y: 72), CGPoint(x: 92, y: 72), CGPoint(x: 70, y: 132)])
                cone.closeSubpath()
                ctx.stroke(cone, with: .color(color.opacity(0.55 * alpha)),
                           style: StrokeStyle(lineWidth: 2.5, lineJoin: .round))
                var waffle = ctx
                waffle.clip(to: cone)
                var grid = Path()
                for i in -6..<8 {
                    let d = CGFloat(i) * 9
                    grid.move(to: CGPoint(x: 40 + d, y: 70)); grid.addLine(to: CGPoint(x: 70 + d, y: 134))
                    grid.move(to: CGPoint(x: 100 - d, y: 70)); grid.addLine(to: CGPoint(x: 70 - d, y: 134))
                }
                waffle.stroke(grid, with: .color(color.opacity(0.25 * alpha)), lineWidth: 1.5)

                // The scoop, sagging, with drips hanging below it.
                let r: CGFloat = 22 - melt * 7
                let sy: CGFloat = 58 + melt * 10
                let base: CGFloat = sy + 6
                let drips: [(CGFloat, CGFloat)] = [(-16, 0.9), (-7, 0.5), (3, 1.2), (13, 0.7), (20, 0.4)]

                var scoop = Path()
                scoop.addArc(center: CGPoint(x: cx, y: sy), radius: r,
                             startAngle: .radians(.pi), endAngle: .radians(0), clockwise: false)
                scoop.addLine(to: CGPoint(x: cx + r + 2, y: base))
                for (dx, len) in drips.reversed() {
                    let tip: CGFloat = base + (6 + len * melt * 30) * 0.6
                    scoop.addQuadCurve(to: CGPoint(x: cx + dx + 3, y: tip),
                                       control: CGPoint(x: cx + dx + 4, y: base))
                    scoop.addArc(center: CGPoint(x: cx + dx, y: tip), radius: 3,
                                 startAngle: .radians(0), endAngle: .radians(.pi), clockwise: false)
                    scoop.addQuadCurve(to: CGPoint(x: cx + dx - 6, y: base),
                                       control: CGPoint(x: cx + dx - 4, y: base))
                }
                scoop.addLine(to: CGPoint(x: cx - r - 2, y: base))
                scoop.closeSubpath()
                ctx.fill(scoop, with: .color(color.opacity(alpha)))

                // A drop falling from the longest drip.
                if melt > 0.3 {
                    let d = M.frac(t / 1.4)
                    let y: CGFloat = base + 0.6 * (6 + 1.2 * melt * 30) + CGFloat(d) * 40
                    ctx.fill(.ellipse(CGPoint(x: cx + 3, y: y), 2.5, 3.5),
                             with: .color(color.opacity(alpha * (1 - d))))
                }

                // Puddle.
                ctx.fill(.ellipse(CGPoint(x: cx + 4, y: 134), 6 + melt * 16, 2.5 + melt * 2),
                         with: .color(color.opacity(0.35 * alpha * Double(melt))))

                // Fresh scoop popping in.
                if refill > 0 {
                    let rr: CGFloat = 22 * refill
                    var fresh = Path()
                    fresh.addArc(center: CGPoint(x: cx, y: 58), radius: rr,
                                 startAngle: .radians(.pi), endAngle: .radians(0), clockwise: false)
                    fresh.addLine(to: CGPoint(x: cx + rr, y: 64))
                    fresh.addLine(to: CGPoint(x: cx - rr, y: 64))
                    fresh.closeSubpath()
                    ctx.fill(fresh, with: .color(color.opacity(Double(refill))))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("MeltingIceCream") {
    SpinnerPreviewStage(name: "MeltingIceCream") {
        MeltingIceCream().frame(width: 120, height: 120)
        HStack(spacing: 32) {
            MeltingIceCream(color: .mint, period: 4).frame(width: 44, height: 44)
            MeltingIceCream(color: .orange).frame(width: 44, height: 44)
        }
    }
}
