//
//  ClockSpinner.swift
//  Spinners
//

import SwiftUI

/// A clock face whose hands spin around: the minute hand fast, the hour hand slower.
public struct ClockSpinner: View {
    var color: Color = SpinnerPalette.teal
    /// Seconds per turn of the minute hand.
    var minutePeriod: Double = 1.2
    /// Seconds per turn of the hour hand.
    var hourPeriod: Double = 6


    public init(
        color: Color = SpinnerPalette.teal,
        minutePeriod: Double = 1.2,
        hourPeriod: Double = 6
    ) {
        self.color = color
        self.minutePeriod = minutePeriod
        self.hourPeriod = hourPeriod
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let stroke = side * 0.045
                let r = (side - stroke) / 2

                ctx.stroke(Path(ellipseIn: CGRect(x: c.x - r, y: c.y - r, width: r * 2, height: r * 2)),
                           with: .color(color), lineWidth: stroke)

                func point(_ degrees: Double, _ length: CGFloat) -> CGPoint {
                    let a = (degrees - 90) * .pi / 180
                    return CGPoint(x: c.x + cos(a) * length, y: c.y + sin(a) * length)
                }
                func dot(_ p: CGPoint, _ d: CGFloat) {
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - d / 2, y: p.y - d / 2, width: d, height: d)),
                             with: .color(color))
                }

                // 12, 3, 6, 9 markers.
                for k in 0..<4 { dot(point(Double(k) * 90, r * 0.75), stroke * 0.9) }

                func hand(_ degrees: Double, _ length: CGFloat, _ width: CGFloat) {
                    var p = Path()
                    p.move(to: c)
                    p.addLine(to: point(degrees, length))
                    ctx.stroke(p, with: .color(color), style: StrokeStyle(lineWidth: width, lineCap: .round))
                }
                hand(SpinnerMath.frac(t / hourPeriod) * 360, r * 0.42, stroke * 1.1)
                hand(SpinnerMath.frac(t / minutePeriod) * 360, r * 0.66, stroke * 0.8)
                dot(c, stroke * 1.4)
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("ClockSpinner") {
    SpinnerPreviewStage(name: "ClockSpinner") {
        ClockSpinner().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            ClockSpinner(color: .pink, minutePeriod: 0.8).frame(width: 36, height: 36)
            ClockSpinner(color: .cyan).frame(width: 36, height: 36)
        }
    }
}
