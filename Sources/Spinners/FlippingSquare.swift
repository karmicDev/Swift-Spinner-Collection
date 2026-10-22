//
//  FlippingSquare.swift
//  Spinners
//

import SwiftUI

/// A rounded square that flips over its horizontal axis, pauses,
/// then flips over its vertical axis.
public struct FlippingSquare: View {
    var color: Color = SpinnerPalette.cyan
    /// Seconds for both flips including the pauses.
    var period: Double = 2.0


    public init(
        color: Color = SpinnerPalette.cyan,
        period: Double = 2.0
    ) {
        self.color = color
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let p = SpinnerMath.frac(t / period)
                // 0–35%: flip around X, 35–50%: hold, 50–85%: flip around Y, 85–100%: hold.
                let xAngle = Double.pi * SpinnerMath.ease(p / 0.35)
                let yAngle = Double.pi * SpinnerMath.ease((p - 0.5) / 0.35)
                let scaleY = abs(cos(xAngle))
                let scaleX = abs(cos(yAngle))
                let edgeOn = 1 - min(scaleX, scaleY)

                let side = min(size.width, size.height) * 0.62
                let w = max(side * scaleX, side * 0.08)
                let h = max(side * scaleY, side * 0.08)
                let rect = CGRect(x: (size.width - w) / 2, y: (size.height - h) / 2, width: w, height: h)
                let corner = min(side * 0.2, min(w, h) / 2)

                // Darken a little while edge-on, like the face turning away from the light.
                ctx.fill(Path(roundedRect: rect, cornerRadius: corner, style: .continuous),
                         with: .color(color.opacity(1 - 0.3 * edgeOn)))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("FlippingSquare") {
    SpinnerPreviewStage(name: "FlippingSquare") {
        FlippingSquare().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            FlippingSquare(color: .pink, period: 1.4).frame(width: 36, height: 36)
            FlippingSquare(color: .orange).frame(width: 36, height: 36)
        }
    }
}
