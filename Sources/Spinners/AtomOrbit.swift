//
//  AtomOrbit.swift
//  Spinners
//

import SwiftUI

/// A nucleus with three electrons circling on tilted elliptical orbits.
public struct AtomOrbit: View {
    var color: Color = SpinnerPalette.cyan
    /// Seconds per orbit for the fastest electron.
    var period: Double = 1.3


    public init(
        color: Color = SpinnerPalette.cyan,
        period: Double = 1.3
    ) {
        self.color = color
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let rx = side * 0.45
                let ry = side * 0.16
                let electron = side * 0.08
                let nucleus = side * 0.16

                let tilts: [Double] = [0, 60, 120]
                let speeds: [Double] = [1, 0.85, 1.15]

                for (k, tilt) in tilts.enumerated() {
                    var orbitCtx = ctx
                    orbitCtx.translateBy(x: c.x, y: c.y)
                    orbitCtx.rotate(by: .degrees(tilt))

                    orbitCtx.stroke(Path(ellipseIn: CGRect(x: -rx, y: -ry, width: rx * 2, height: ry * 2)),
                                    with: .color(color.opacity(0.25)), lineWidth: max(side * 0.012, 0.5))

                    let a = t / period * speeds[k] * 2 * .pi + Double(k) * 2.1
                    let p = CGPoint(x: rx * cos(a), y: ry * sin(a))
                    orbitCtx.fill(Path(ellipseIn: CGRect(x: p.x - electron / 2, y: p.y - electron / 2,
                                                         width: electron, height: electron)),
                                  with: .color(color))
                }

                ctx.fill(Path(ellipseIn: CGRect(x: c.x - nucleus / 2, y: c.y - nucleus / 2,
                                                width: nucleus, height: nucleus)),
                         with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("AtomOrbit") {
    SpinnerPreviewStage(name: "AtomOrbit") {
        AtomOrbit().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            AtomOrbit(color: .pink, period: 0.9).frame(width: 36, height: 36)
            AtomOrbit(color: .mint).frame(width: 36, height: 36)
        }
    }
}
