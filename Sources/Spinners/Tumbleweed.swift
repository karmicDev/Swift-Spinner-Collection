//
//  Tumbleweed.swift
//  Spinners
//

import SwiftUI

/// A tangle of dry branches bouncing across the desert, spinning as it rolls,
/// kicking up dust on every landing while gusts of wind blow past.
public struct Tumbleweed: View {
    var color: Color = SpinnerPalette.dough
    /// Seconds to roll across the whole view.
    var crossDuration: Double = 3.2
    /// Seconds per bounce.
    var hopDuration: Double = 0.8

    /// Branch arcs inside the ball: (angle of offset, size, rotation, arc length in radians).
    private static let strands: [(Double, Double, Double, Double)] = (0..<18).map { i in
        let d = Double(i)
        return (SpinnerMath.rnd(d) * 2 * .pi,
                6 + SpinnerMath.rnd(d + 30) * 10,
                SpinnerMath.rnd(d + 60) * 2 * .pi,
                1.6 + SpinnerMath.rnd(d + 90) * 2.2)
    }


    public init(
        color: Color = SpinnerPalette.dough,
        crossDuration: Double = 3.2,
        hopDuration: Double = 0.8
    ) {
        self.color = color
        self.crossDuration = crossDuration
        self.hopDuration = hopDuration
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self
                let ground: CGFloat = 112
                let R: CGFloat = 17
                let round = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

                let x: CGFloat = -R - 6 + CGFloat(M.frac(t / crossDuration)) * (140 + 2 * R + 12)
                let hop = M.frac(t / hopDuration)
                let bounce = CGFloat(abs(sin(hop * .pi)) * 20 * (0.8 + 0.2 * sin(t * 1.3)))
                let y: CGFloat = ground - R - bounce
                let spin = Double(x / R)   // rolling without slipping

                // Ground, a dune and a little cactus.
                var line = Path()
                line.move(to: CGPoint(x: 6, y: ground))
                line.addLine(to: CGPoint(x: 134, y: ground))
                ctx.stroke(line, with: .color(color.opacity(0.5)),
                           style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                var dune = Path()
                dune.move(to: CGPoint(x: 98, y: ground))
                dune.addQuadCurve(to: CGPoint(x: 120, y: ground), control: CGPoint(x: 108, y: ground - 10))
                ctx.fill(dune, with: .color(color.opacity(0.35)))

                var cactus = Path()
                cactus.move(to: CGPoint(x: 26, y: ground)); cactus.addLine(to: CGPoint(x: 26, y: ground - 22))
                cactus.move(to: CGPoint(x: 26, y: ground - 12))
                cactus.addLines([CGPoint(x: 26, y: ground - 12), CGPoint(x: 20, y: ground - 12), CGPoint(x: 20, y: ground - 18)])
                cactus.move(to: CGPoint(x: 26, y: ground - 15))
                cactus.addLines([CGPoint(x: 26, y: ground - 15), CGPoint(x: 32, y: ground - 15), CGPoint(x: 32, y: ground - 21)])
                ctx.stroke(cactus, with: .color(color.opacity(0.4)), style: round)

                // Gusts of wind.
                for i in 0..<3 {
                    let d = Double(i)
                    let q = M.frac(t * 0.9 + d / 3)
                    let wy = 40 + d * 16 + M.rnd(d) * 6
                    var gust = Path()
                    gust.move(to: CGPoint(x: q * 160 - 30, y: wy))
                    gust.addLine(to: CGPoint(x: q * 160 - 6, y: wy))
                    ctx.stroke(gust, with: .color(color.opacity(0.3 * sin(q * .pi))),
                               style: StrokeStyle(lineWidth: 1.5, lineCap: .round))
                }

                // Shadow: tighter and darker the closer it is to the ground.
                let near = Double(1 - bounce / 24)
                ctx.fill(.ellipse(CGPoint(x: x, y: ground + 3), R * CGFloat(0.6 + 0.5 * near), 2.5),
                         with: .color(color.opacity(0.18 + 0.18 * near)))

                // Dust kicked up on landing.
                if hop < 0.25 || hop > 0.9 {
                    let k: CGFloat = hop < 0.25 ? CGFloat(hop / 0.25) : 0
                    for i in 0..<4 {
                        let d = CGFloat(i)
                        let jitter = CGFloat(M.rnd(Double(i))) * 3
                        let pt = CGPoint(x: x - R * 0.4 - d * 5 - k * 8, y: ground - 2 - k * 5 - jitter)
                        ctx.fill(.circle(pt, 2 + k * 3), with: .color(color.opacity(Double(0.4 * (1 - k)))))
                    }
                }

                // The tumbleweed itself.
                var weed = ctx
                weed.translateBy(x: x, y: y)
                weed.rotate(by: .radians(spin))
                weed.stroke(.circle(.zero, R), with: .color(color.opacity(0.9)), lineWidth: 1.6)
                for (i, strand) in Self.strands.enumerated() {
                    let (offsetAngle, r, rotation, length) = strand
                    let ox: Double = cos(offsetAngle) * (Double(R) - r) * 0.6
                    let oy: Double = sin(offsetAngle) * (Double(R) - r) * 0.6
                    var arc = Path()
                    for k in 0...14 {
                        let th = length * Double(k) / 14
                        let lx = r * cos(th), ly = r * 0.55 * sin(th)
                        let px: Double = ox + lx * cos(rotation) - ly * sin(rotation)
                        let py: Double = oy + lx * sin(rotation) + ly * cos(rotation)
                        let pt = CGPoint(x: px, y: py)
                        if k == 0 { arc.move(to: pt) } else { arc.addLine(to: pt) }
                    }
                    let d = Double(i)
                    weed.stroke(arc, with: .color(color.opacity(0.55 + 0.4 * M.rnd(d + 5))),
                                style: StrokeStyle(lineWidth: 1.2 + M.rnd(d + 8) * 0.8, lineCap: .round))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("Tumbleweed") {
    SpinnerPreviewStage(name: "Tumbleweed") {
        Tumbleweed().frame(width: 140, height: 140)
        HStack(spacing: 32) {
            Tumbleweed(color: .orange, crossDuration: 2).frame(width: 48, height: 48)
            Tumbleweed(color: .mint).frame(width: 48, height: 48)
        }
    }
}
