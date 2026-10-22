//
//  BouncingDots.swift
//  SpinnerCollection
//

import SwiftUI

/// Three dots that hop one after another, brightening at the top of each hop.
struct BouncingDots: View {
    var color: Color = SpinnerPalette.violet
    var dotCount: Int = 3
    /// Seconds for the wave to pass through all dots and rest.
    var period: Double = 1.2

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let n = max(dotCount, 1)
                let side = min(size.width, size.height)
                let d = side * 0.2
                let gap = d * 0.45
                let totalWidth = CGFloat(n) * d + CGFloat(n - 1) * gap
                let startX = (size.width - totalWidth) / 2
                let baseY = size.height / 2 + d * 0.6
                let hop = d * 1.1

                for i in 0..<n {
                    let p = SpinnerMath.frac(t / period - Double(i) * 0.12)
                    // Hop during the first 40% of the cycle, rest otherwise.
                    let lift = p < 0.4 ? sin(p / 0.4 * .pi) : 0
                    let x = startX + CGFloat(i) * (d + gap)
                    let y = baseY - d / 2 - hop * lift
                    ctx.fill(Path(ellipseIn: CGRect(x: x, y: y - d / 2, width: d, height: d)),
                             with: .color(color.opacity(0.5 + 0.5 * lift)))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("BouncingDots") {
    SpinnerPreviewStage(name: "BouncingDots") {
        BouncingDots().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            BouncingDots(color: .pink, dotCount: 4).frame(width: 44, height: 44)
            BouncingDots(color: .mint, period: 0.8).frame(width: 44, height: 44)
        }
    }
}
