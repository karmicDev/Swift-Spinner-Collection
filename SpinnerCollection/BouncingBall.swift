//
//  BouncingBall.swift
//  SpinnerCollection
//

import SwiftUI

/// A ball bouncing under gravity, squashing on impact, with a shadow
/// that tightens and darkens as it lands.
struct BouncingBall: View {
    var color: Color = SpinnerPalette.cyan
    /// Seconds per bounce.
    var period: Double = 0.9

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let r = side * 0.09
                let floorY = size.height / 2 + side * 0.36
                let jump = side * 0.55
                let cx = size.width / 2

                let p = SpinnerMath.frac(t / period)
                let height = 4 * p * (1 - p)                  // parabola: 0 → 1 → 0
                let nearFloor = min(p, 1 - p)
                let squash = max(0, 1 - nearFloor / 0.07) * 0.25

                // Shadow.
                let sw = r * 2 * (1.1 - 0.5 * height)
                let sh = r * 0.4
                ctx.fill(Path(ellipseIn: CGRect(x: cx - sw / 2, y: floorY - sh / 2, width: sw, height: sh)),
                         with: .color(color.opacity(0.08 + 0.25 * (1 - height))))

                // Ball, squashed when touching the floor.
                let bw = r * 2 * (1 + squash)
                let bh = r * 2 * (1 - squash)
                let bottom = floorY - jump * height
                ctx.fill(Path(ellipseIn: CGRect(x: cx - bw / 2, y: bottom - bh, width: bw, height: bh)),
                         with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("BouncingBall") {
    SpinnerPreviewStage(name: "BouncingBall") {
        BouncingBall().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            BouncingBall(color: .pink, period: 0.6).frame(width: 36, height: 36)
            BouncingBall(color: .orange).frame(width: 36, height: 36)
        }
    }
}
