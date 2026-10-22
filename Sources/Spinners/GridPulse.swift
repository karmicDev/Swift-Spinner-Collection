//
//  GridPulse.swift
//  Spinners
//

import SwiftUI

/// A 3×3 grid of rounded tiles that shrink away and grow back in a diagonal wave.
public struct GridPulse: View {
    var color: Color = SpinnerPalette.teal
    var gridSize: Int = 3
    /// Seconds for one full wave.
    var period: Double = 1.8


    public init(
        color: Color = SpinnerPalette.teal,
        gridSize: Int = 3,
        period: Double = 1.8
    ) {
        self.color = color
        self.gridSize = gridSize
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let n = max(gridSize, 1)
                let side = min(size.width, size.height) * 0.85
                let cell = side / CGFloat(n)
                let tile = cell * 0.82
                let origin = CGPoint(x: (size.width - side) / 2, y: (size.height - side) / 2)

                for row in 0..<n {
                    for col in 0..<n {
                        let diagonal = Double(row + col)
                        let p = SpinnerMath.frac(t / period - diagonal * 0.1)
                        let v = 0.5 + 0.5 * cos(p * 2 * .pi)   // 1 → 0 → 1
                        let s = tile * v
                        guard s > 0.5 else { continue }
                        let cx = origin.x + (CGFloat(col) + 0.5) * cell
                        let cy = origin.y + (CGFloat(row) + 0.5) * cell
                        let rect = CGRect(x: cx - s / 2, y: cy - s / 2, width: s, height: s)
                        ctx.fill(Path(roundedRect: rect, cornerRadius: s * 0.22),
                                 with: .color(color.opacity(0.35 + 0.65 * v)))
                    }
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("GridPulse") {
    SpinnerPreviewStage(name: "GridPulse") {
        GridPulse().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            GridPulse(color: .pink, gridSize: 4).frame(width: 36, height: 36)
            GridPulse(color: .cyan, period: 1.2).frame(width: 36, height: 36)
        }
    }
}
