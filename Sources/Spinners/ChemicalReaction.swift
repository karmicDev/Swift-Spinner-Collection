//
//  ChemicalReaction.swift
//  Spinners
//

import SwiftUI

/// A flask of sloshing liquid: bubbles rise and pop at the surface
/// while puffs of smoke drift out of the neck.
public struct ChemicalReaction: View {
    var color: Color = SpinnerPalette.teal


    public init(
        color: Color = SpinnerPalette.teal
    ) {
        self.color = color
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self

                var flask = Path()
                flask.move(to: CGPoint(x: 58, y: 30))
                flask.addLine(to: CGPoint(x: 58, y: 62))
                flask.addLine(to: CGPoint(x: 28, y: 116))
                flask.addQuadCurve(to: CGPoint(x: 32, y: 124), control: CGPoint(x: 24, y: 124))
                flask.addLine(to: CGPoint(x: 108, y: 124))
                flask.addQuadCurve(to: CGPoint(x: 112, y: 116), control: CGPoint(x: 116, y: 124))
                flask.addLine(to: CGPoint(x: 82, y: 62))
                flask.addLine(to: CGPoint(x: 82, y: 30))

                var clipShape = flask
                clipShape.closeSubpath()
                let level = 84.0

                var inside = ctx
                inside.clip(to: clipShape)

                // Liquid with a gentle wave on top.
                var liquid = Path()
                liquid.move(to: CGPoint(x: 20, y: 130))
                for x in stride(from: 20.0, through: 120.0, by: 4.0) {
                    liquid.addLine(to: CGPoint(x: x, y: level + 3 * sin(x * 0.12 + t * 4)))
                }
                liquid.addLine(to: CGPoint(x: 120, y: 130))
                liquid.closeSubpath()
                inside.fill(liquid, with: .color(color.opacity(0.35)))

                // Rising bubbles.
                for i in 0..<9 {
                    let d = Double(i)
                    let p = M.frac(t * 0.7 + M.rnd(d))
                    let x = 44 + M.rnd(d + 20) * 52 + 4 * sin(t * 3 + d)
                    let y = 120 - p * (120 - level)
                    let r = 2 + M.rnd(d + 40) * 3 + p * 1.5
                    inside.fill(.circle(CGPoint(x: x, y: y), r),
                                with: .color(color.opacity(0.9 * (1 - p * 0.4))))
                }

                // Glass and rim.
                let glass = StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                ctx.stroke(flask, with: .color(color), style: glass)
                var rim = Path()
                rim.move(to: CGPoint(x: 52, y: 30))
                rim.addLine(to: CGPoint(x: 88, y: 30))
                ctx.stroke(rim, with: .color(color), style: glass)

                // Smoke puffs drifting up from the neck.
                for i in 0..<5 {
                    let d = Double(i)
                    let p = M.frac(t * 0.45 + d / 5)
                    let x = 70 + sin(p * 6 + d) * 10 * p
                    let y = 26 - p * 24
                    ctx.fill(.circle(CGPoint(x: x, y: y), 4 + p * 9),
                             with: .color(color.opacity(0.45 * (1 - p))))
                }

                // Bubbles popping at the surface.
                for i in 0..<4 {
                    let d = Double(i)
                    let p = M.frac(t * 1.3 + d / 4)
                    guard p > 0.75 else { continue }
                    let k = (p - 0.75) / 0.25
                    var pop = Path()
                    pop.addArc(center: CGPoint(x: 58 + d * 8, y: level - 2), radius: 3 + k * 5,
                               startAngle: .radians(.pi * 1.1), endAngle: .radians(.pi * 1.9),
                               clockwise: false)
                    ctx.stroke(pop, with: .color(color.opacity(1 - k)), lineWidth: 1.5)
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("ChemicalReaction") {
    SpinnerPreviewStage(name: "ChemicalReaction") {
        ChemicalReaction().frame(width: 120, height: 120)
        HStack(spacing: 32) {
            ChemicalReaction(color: .pink).frame(width: 44, height: 44)
            ChemicalReaction(color: .orange).frame(width: 44, height: 44)
        }
    }
}
