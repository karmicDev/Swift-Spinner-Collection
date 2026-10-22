//
//  PulseRipple.swift
//  SpinnerCollection
//

import SwiftUI

/// A softly pulsing core that sends rings rippling outward and fading away.
struct PulseRipple: View {
    var color: Color = SpinnerPalette.amber
    /// Seconds for one ring to travel from the core to the edge.
    var period: Double = 1.6
    var ringCount: Int = 3

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let maxRadius = side * 0.47
                let stroke = side * 0.028

                func circle(_ r: CGFloat) -> Path {
                    Path(ellipseIn: CGRect(x: center.x - r, y: center.y - r,
                                           width: r * 2, height: r * 2))
                }

                // Faint static outer boundary.
                ctx.stroke(circle(maxRadius), with: .color(color.opacity(0.25)),
                           lineWidth: stroke * 0.6)

                // Expanding ripples.
                let coreRadius = side * 0.1
                for k in 0..<max(ringCount, 1) {
                    let p = SpinnerMath.frac(t / period + Double(k) / Double(max(ringCount, 1)))
                    let r = coreRadius + (maxRadius - coreRadius) * p
                    let alpha = pow(1 - p, 1.4) * 0.95
                    ctx.stroke(circle(r), with: .color(color.opacity(alpha)), lineWidth: stroke)
                }

                // Pulsing core.
                let pulse = 1 + 0.15 * sin(t / period * 2 * .pi)
                ctx.fill(circle(coreRadius * pulse), with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("PulseRipple") {
    SpinnerPreviewStage(name: "PulseRipple") {
        PulseRipple().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            PulseRipple(color: .cyan, period: 1.0).frame(width: 36, height: 36)
            PulseRipple(color: .pink, ringCount: 2).frame(width: 36, height: 36)
        }
    }
}
