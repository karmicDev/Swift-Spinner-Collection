//
//  CookieBites.swift
//  Spinners
//

import SwiftUI

/// A chocolate chip cookie eaten in big bites with tooth marks until nothing is left,
/// then a fresh cookie appears.
///
/// Drawn in one color: the chips and toasted spots are cut out of the dough and
/// refilled with a fainter tint, so they read as darker on a dark background and
/// still work with the color slider and gradient.
public struct CookieBites: View {
    var color: Color = SpinnerPalette.dough
    /// Seconds for the whole cookie to be eaten and come back.
    var period: Double = 6

    /// (start time as fraction of the cycle, direction in radians, bite radius)
    private static let bites: [(Double, Double, CGFloat)] = [
        (0.08, 0.2, 40), (0.24, 3.0, 38), (0.42, -1.6, 40), (0.6, 1.9, 36), (0.76, 0, 60),
    ]
    private static let chips: [(CGFloat, CGFloat, CGFloat)] = [
        (-16, -14, 7), (12, -26, 6), (24, -4, 7), (0, 4, 6), (-26, 8, 6),
        (10, 22, 7), (-8, 32, 5), (30, 18, 5), (-30, -12, 5), (4, -12, 4),
    ]
    private static let spots: [(CGFloat, CGFloat, CGFloat)] = [
        (-20, -24, 5), (22, 16, 4), (-10, 26, 4), (30, -10, 3),
    ]


    public init(
        color: Color = SpinnerPalette.dough,
        period: Double = 6
    ) {
        self.color = color
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 160)
                let M = SpinnerMath.self
                let p = M.frac(t / period)
                let center = CGPoint(x: 80, y: 74)
                let radius: CGFloat = 46

                // The cookie with bites taken out of it.
                ctx.drawLayer { layer in
                    drawCookie(in: &layer, center: center, radius: radius)

                    layer.blendMode = .destinationOut
                    for (i, bite) in Self.bites.enumerated() {
                        let k = M.ease((p - bite.0) / 0.06)
                        guard k > 0 else { continue }
                        let isLast = i == Self.bites.count - 1
                        let dist: CGFloat = isLast ? 0 : radius * 0.92
                        let b = CGPoint(x: center.x + CGFloat(cos(bite.1)) * dist,
                                        y: center.y + CGFloat(sin(bite.1)) * dist)
                        let r: CGFloat = bite.2 * CGFloat(k)
                        layer.fill(.circle(b, r), with: .color(.black))
                        guard !isLast else { continue }
                        // Tooth marks: little scallops along the edge of the bite.
                        for j in 0..<9 {
                            let a = bite.1 + .pi + (Double(j) / 8 - 0.5) * 2.2
                            layer.fill(.circle(CGPoint(x: b.x + CGFloat(cos(a)) * r, y: b.y + CGFloat(sin(a)) * r), 4.2 * CGFloat(k)),
                                       with: .color(.black))
                        }
                    }
                }

                // Crumbs that fall from each bite and fade away.
                for (i, bite) in Self.bites.enumerated() {
                    let q = M.clamp((p - bite.0) / 0.12)
                    guard q > 0, q < 1 else { continue }
                    let isLast = i == Self.bites.count - 1
                    let dist: CGFloat = isLast ? 0 : radius * 0.92
                    let b = CGPoint(x: center.x + CGFloat(cos(bite.1)) * dist,
                                    y: center.y + CGFloat(sin(bite.1)) * dist)
                    let r: CGFloat = bite.2 * CGFloat(M.ease((p - bite.0) / 0.06))
                    for j in 0..<5 {
                        let s = M.rnd(Double(i * 11 + j))
                        let ex: CGFloat = b.x + CGFloat(cos(bite.1 + .pi)) * r * 0.6 + CGFloat(s - 0.5) * 24
                        let crumb = CGPoint(x: ex + CGFloat((s - 0.5) * 10 * q), y: b.y + CGFloat(q * q * 60))
                        let shade = j % 2 == 1 ? 0.35 : 1.0
                        ctx.fill(.circle(crumb, CGFloat(1.5 + s * 2)), with: .color(color.opacity((1 - q) * shade)))
                    }
                }

                // A fresh cookie grows back in.
                if p > 0.9 {
                    let f = CGFloat((p - 0.9) / 0.1)
                    var fresh = ctx
                    fresh.opacity = Double(f)
                    fresh.drawLayer { layer in
                        layer.translateBy(x: center.x, y: center.y)
                        layer.scaleBy(x: 0.6 + 0.4 * f, y: 0.6 + 0.4 * f)
                        layer.translateBy(x: -center.x, y: -center.y)
                        drawCookie(in: &layer, center: center, radius: radius)
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }

    /// Dough with an uneven edge, toasted spots and chunky chocolate chips.
    private func drawCookie(in layer: inout GraphicsContext, center: CGPoint, radius: CGFloat) {
        let M = SpinnerMath.self

        var dough = Path()
        for i in 0...48 {
            let a = Double(i) / 48 * 2 * .pi
            let r: CGFloat = radius + CGFloat(sin(a * 7) * 1.5 + sin(a * 3 + 1) * 1.2)
            let pt = CGPoint(x: center.x + CGFloat(cos(a)) * r, y: center.y + CGFloat(sin(a)) * r)
            if i == 0 { dough.move(to: pt) } else { dough.addLine(to: pt) }
        }
        dough.closeSubpath()
        layer.fill(dough, with: .color(color))

        var spots = Path()
        for (x, y, r) in Self.spots {
            spots.addPath(.circle(CGPoint(x: center.x + x, y: center.y + y), r))
        }
        var chips = Path()
        for (i, chip) in Self.chips.enumerated() {
            var shape = Path()
            for j in 0..<6 {
                let a = Double(j) / 6 * 2 * .pi + Double(i)
                let r: CGFloat = chip.2 * CGFloat(0.75 + M.rnd(Double(i * 9 + j)) * 0.45)
                let pt = CGPoint(x: center.x + chip.0 + CGFloat(cos(a)) * r,
                                 y: center.y + chip.1 + CGFloat(sin(a)) * r * 0.85)
                if j == 0 { shape.move(to: pt) } else { shape.addLine(to: pt) }
            }
            shape.closeSubpath()
            chips.addPath(shape)
        }

        // Cut the chips and spots out, then refill them more faintly so they look darker.
        layer.blendMode = .destinationOut
        layer.fill(spots, with: .color(.black))
        layer.fill(chips, with: .color(.black))
        layer.blendMode = .normal
        layer.fill(spots, with: .color(color.opacity(0.7)))
        layer.fill(chips, with: .color(color.opacity(0.28)))
    }
}

#Preview("CookieBites") {
    SpinnerPreviewStage(name: "CookieBites") {
        CookieBites().frame(width: 120, height: 120)
        HStack(spacing: 32) {
            CookieBites(color: .pink, period: 4).frame(width: 44, height: 44)
            CookieBites(color: .mint).frame(width: 44, height: 44)
        }
    }
}
