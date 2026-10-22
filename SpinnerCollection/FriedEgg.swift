//
//  FriedEgg.swift
//  SpinnerCollection
//

import SwiftUI

/// An egg drops into a pan, taps the rim, cracks and splits open.
/// The white splashes out, the yolk lands with a squash, and it sizzles
/// with popping bubbles and steam before fading out and starting again.
struct FriedEgg: View {
    var color: Color = SpinnerPalette.amber
    /// Seconds for one crack-fry-fade cycle.
    var period: Double = 5

    /// Overshooting ease: rises past 1, then settles back (for the splash and the yolk).
    private static func outBack(_ value: Double) -> Double {
        let x = SpinnerMath.clamp(value) - 1
        return 1 + 2.7 * x * x * x + 1.7 * x * x
    }

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self
                let p = M.frac(t / period)
                let cx = 66.0, cy = 84.0
                // Egg white and shell: a very light version of the tint, so the slider still recolors it.
                let white = color.mix(with: .white, by: 0.85)
                let round = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)

                // Pan with handle.
                var handle = Path()
                handle.move(to: CGPoint(x: cx + 40, y: cy + 26))
                handle.addLine(to: CGPoint(x: cx + 64, y: cy + 44))
                ctx.stroke(handle, with: .color(color.opacity(0.6)),
                           style: StrokeStyle(lineWidth: 9, lineCap: .round))
                ctx.fill(.circle(CGPoint(x: cx, y: cy), 46), with: .color(color.opacity(0.12)))
                ctx.stroke(.circle(CGPoint(x: cx, y: cy), 46), with: .color(color.opacity(0.6)), style: round)

                let fade = p > 0.88 ? 1 - (p - 0.88) / 0.12 : 1
                let drop = M.ease(p / 0.12)
                let tap = (p > 0.12 && p < 0.22) ? sin((p - 0.12) / 0.1 * .pi * 3) * 2 : 0
                let crack = M.clamp((p - 0.16) / 0.06)
                let split = M.ease((p - 0.24) / 0.12)
                let ex = cx + 4
                let ey = -10 + drop * 30

                // The jagged crack line, top to bottom.
                let crackPoints: [CGPoint] = [
                    CGPoint(x: 0, y: -15), CGPoint(x: -2, y: -8), CGPoint(x: 2, y: -3),
                    CGPoint(x: -1, y: 2), CGPoint(x: 3, y: 8), CGPoint(x: 0, y: 15),
                ]

                // Shell: two halves that split apart and fade.
                if p < 0.38 {
                    let shellAlpha = 1 - M.clamp((split - 0.6) / 0.4)
                    for side in [-1.0, 1.0] {
                        var half = ctx
                        half.translateBy(x: ex + side * split * 14, y: ey + tap - split * 4)
                        half.rotate(by: .radians(side * split * 0.7))
                        var shell = Path()
                        shell.addLines(crackPoints)
                        shell.addCurve(to: CGPoint(x: 0, y: -15),
                                       control1: CGPoint(x: side * 16, y: 15),
                                       control2: CGPoint(x: side * 14, y: -15))
                        shell.closeSubpath()
                        half.fill(shell, with: .color(white.opacity(0.92 * shellAlpha)))
                    }
                    if crack > 0, split <= 0 {
                        let count = Int((crack * 5).rounded(.up))
                        var line = Path()
                        line.addLines(crackPoints.prefix(count + 1).map {
                            CGPoint(x: ex + Double($0.x), y: ey + tap + Double($0.y))
                        })
                        ctx.stroke(line, with: .color(color), lineWidth: 1.5)
                    }
                }

                // Contents dropping into the pan.
                let fall = M.clamp((p - 0.28) / 0.08)
                if fall > 0, fall < 1 {
                    ctx.fill(.ellipse(CGPoint(x: ex, y: ey + fall * (cy - ey)), 5, 7 + fall * 4),
                             with: .color(color.opacity(0.9)))
                }

                let spread = Self.outBack((p - 0.34) / 0.14)
                guard spread > 0 else { return }
                let crisp = M.clamp((p - 0.5) / 0.3)

                // Egg white splashing out, with a wobbly edge that crisps up.
                var eggWhite = Path()
                for i in 0...40 {
                    let a = Double(i) / 40 * 2 * .pi
                    let r = spread * (26 + sin(a * 3 + 1) * 4 + sin(a * 5) * 2) + sin(t * 6 + a * 4) * 0.6 * crisp
                    let pt = CGPoint(x: cx + 2 + cos(a) * r, y: cy + sin(a) * r * 0.92)
                    if i == 0 { eggWhite.move(to: pt) } else { eggWhite.addLine(to: pt) }
                }
                eggWhite.closeSubpath()
                ctx.fill(eggWhite, with: .color(white.opacity(0.85 * fade)))
                if crisp > 0 {
                    ctx.stroke(eggWhite, with: .color(color.opacity(0.55 * crisp * fade)), lineWidth: 2.5)
                }

                // Yolk landing with a squash, plus a little shine.
                let yolk = Self.outBack((p - 0.36) / 0.12)
                if yolk > 0 {
                    let squash = 1 + 0.25 * sin(M.clamp((p - 0.36) / 0.12) * .pi)
                    ctx.fill(.ellipse(CGPoint(x: cx + 4, y: cy - 2), 10 * yolk * squash, 10 * yolk / squash),
                             with: .color(color.opacity(fade)))
                    var shine = ctx
                    shine.translateBy(x: cx + 1, y: cy - 5)
                    shine.rotate(by: .radians(-0.5))
                    shine.fill(.ellipse(.zero, 3 * yolk, 2 * yolk), with: .color(.white.opacity(0.6 * fade)))
                }

                // Sizzle: bubbles popping around the edge.
                if p > 0.46, p < 0.88 {
                    for i in 0..<10 {
                        let d = Double(i)
                        let q = M.frac(t * 1.6 + M.rnd(d))
                        let a = M.rnd(d + 3) * 2 * .pi
                        let r = 27 + M.rnd(d + 7) * 6
                        let pt = CGPoint(x: cx + 2 + cos(a) * r, y: cy + sin(a) * r * 0.92 - q * 6)
                        ctx.stroke(.circle(pt, 1 + q * 2.5), with: .color(color.opacity(0.8 * (1 - q))),
                                   lineWidth: 1.2)
                    }
                }

                // Steam curling up.
                if p > 0.5, p < 0.86 {
                    for i in 0..<3 {
                        let d = Double(i)
                        let q = M.frac(t * 0.5 + d / 3)
                        let sx = cx - 16 + d * 16
                        let rise = q * 20
                        var steam = Path()
                        steam.move(to: CGPoint(x: sx, y: cy - 26 - rise))
                        steam.addQuadCurve(to: CGPoint(x: sx, y: cy - 42 - rise),
                                           control: CGPoint(x: sx + 5 * sin(t * 3 + d), y: cy - 34 - rise))
                        ctx.stroke(steam, with: .color(white.opacity(0.35 * (1 - q))),
                                   style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("FriedEgg") {
    SpinnerPreviewStage(name: "FriedEgg") {
        FriedEgg().frame(width: 140, height: 140)
        HStack(spacing: 32) {
            FriedEgg(color: .pink, period: 3.5).frame(width: 48, height: 48)
            FriedEgg(color: .cyan).frame(width: 48, height: 48)
        }
    }
}
