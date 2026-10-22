//
//  Seedling.swift
//  SpinnerCollection
//

import SwiftUI

/// A seed pushes up through the soil, unfolds its first leaves, grows two more,
/// sways a little, then fades and starts again.
struct Seedling: View {
    var color: Color = SpinnerPalette.green
    /// Seconds for one full grow-and-fade cycle.
    var period: Double = 4.5

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                ctx.fitSquare(size, design: 140)
                let M = SpinnerMath.self
                let p = M.frac(t / period)
                let grow = min(p / 0.75, 1)
                let fade = p > 0.85 ? 1 - (p - 0.85) / 0.15 : 1
                let ground = 108.0
                let cx = 70.0

                // Soil line and specks of dirt.
                var soil = Path()
                soil.move(to: CGPoint(x: 24, y: ground))
                soil.addLine(to: CGPoint(x: 116, y: ground))
                ctx.stroke(soil, with: .color(color.opacity(0.6)),
                           style: StrokeStyle(lineWidth: 3, lineCap: .round))
                for i in 0..<12 {
                    let d = Double(i)
                    let p = CGPoint(x: 28 + d * 8 + M.rnd(d) * 4, y: ground + 7 + M.rnd(d + 5) * 12)
                    ctx.fill(.circle(p, 1.6), with: .color(color.opacity(0.3)))
                }

                // Bump in the soil before the sprout breaks through.
                let bump = min(grow / 0.25, 1)
                if bump < 1 {
                    var above = ctx
                    above.clip(to: Path(CGRect(x: 0, y: 0, width: 140, height: ground)))
                    above.fill(.ellipse(CGPoint(x: cx, y: ground - 2 + 3 * (1 - bump)), 5 * (0.5 + bump), 3),
                               with: .color(color.opacity(0.5)))
                }
                guard grow >= 0.12 else { return }

                // Stem, swaying gently.
                let s = (grow - 0.12) / 0.88
                let h = 10 + s * 58
                let bend = sin(t * 2) * 2 * s
                var stem = Path()
                stem.move(to: CGPoint(x: cx, y: ground))
                stem.addQuadCurve(to: CGPoint(x: cx + bend, y: ground - h),
                                  control: CGPoint(x: cx - 6 * (1 - s), y: ground - h * 0.5))
                ctx.stroke(stem, with: .color(color.opacity(fade)),
                           style: StrokeStyle(lineWidth: 3.5, lineCap: .round))

                func leaf(at y: Double, dir: Double, size: Double, angle: Double) {
                    guard size > 0 else { return }
                    var l = ctx
                    l.translateBy(x: cx + bend * ((ground - y) / h), y: y)
                    l.rotate(by: .radians(dir * angle))
                    l.fill(.ellipse(CGPoint(x: dir * size * 0.9, y: 0), size, size * 0.45),
                           with: .color(color.opacity(fade * 0.9)))
                }

                // Seed leaves unfold at the top, then two true leaves appear lower down.
                let a = M.clamp((s - 0.1) / 0.3)
                leaf(at: ground - h, dir: -1, size: 10 * a, angle: -0.35 * a)
                leaf(at: ground - h, dir: 1, size: 10 * a, angle: -0.35 * a)
                let b = M.clamp((s - 0.5) / 0.3)
                leaf(at: ground - h * 0.55, dir: 1, size: 9 * b, angle: -0.5)
                let c = M.clamp((s - 0.7) / 0.3)
                leaf(at: ground - h * 0.75, dir: -1, size: 8 * c, angle: -0.5)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("Seedling") {
    SpinnerPreviewStage(name: "Seedling") {
        Seedling().frame(width: 120, height: 120)
        HStack(spacing: 32) {
            Seedling(color: .mint, period: 3).frame(width: 44, height: 44)
            Seedling(color: .pink).frame(width: 44, height: 44)
        }
    }
}
