//
//  StripedBar.swift
//  Spinners
//

import SwiftUI

/// An indeterminate "barber pole" progress bar with diagonal stripes sliding along it.
public struct StripedBar: View {
    var color: Color = SpinnerPalette.amber
    /// Seconds for the stripes to move one stripe-pair along.
    var period: Double = 0.6


    public init(
        color: Color = SpinnerPalette.amber,
        period: Double = 0.6
    ) {
        self.color = color
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let h = size.height
                let bar = Path(roundedRect: CGRect(origin: .zero, size: size), cornerRadius: h / 2)

                var inside = ctx
                inside.clip(to: bar)
                inside.fill(bar, with: .color(color.opacity(0.55)))

                let stripe = h * 0.9                     // stripe width
                let pitch = stripe * 2                   // stripe + gap
                let slant = h                            // 45° lean
                let offset = CGFloat(SpinnerMath.frac(t / period)) * pitch

                var x = -pitch - slant + offset
                while x < size.width + slant {
                    var p = Path()
                    p.move(to: CGPoint(x: x + slant, y: 0))
                    p.addLine(to: CGPoint(x: x + slant + stripe, y: 0))
                    p.addLine(to: CGPoint(x: x + stripe, y: h))
                    p.addLine(to: CGPoint(x: x, y: h))
                    p.closeSubpath()
                    inside.fill(p, with: .color(color))
                    x += pitch
                }
            }
        }
        .aspectRatio(7, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("StripedBar") {
    SpinnerPreviewStage(name: "StripedBar") {
        StripedBar().frame(width: 220)
        StripedBar(color: .pink, period: 0.4).frame(width: 120)
        StripedBar(color: .cyan).frame(width: 120)
    }
}
