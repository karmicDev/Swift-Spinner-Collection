//
//  NewtonCradle.swift
//  SpinnerCollection
//

import SwiftUI

/// Newton's cradle: the outer balls swing out and knock each other through the middle row.
struct NewtonCradle: View {
    var color: Color = SpinnerPalette.violet
    var ballCount: Int = 5
    /// Seconds for one left + right swing.
    var period: Double = 1.4
    /// Maximum swing angle in degrees.
    var maxAngle: Double = 35

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let n = max(ballCount, 2)
                let side = min(size.width, size.height)
                let d = side * 0.75 / (CGFloat(n) + 1.6)        // ball diameter
                let length = side * 0.36                        // string length
                let barY = size.height / 2 - length * 0.65
                let barHalf = d * (CGFloat(n) / 2 + 0.8)
                let cx = size.width / 2

                // Top bar.
                var bar = Path()
                bar.move(to: CGPoint(x: cx - barHalf, y: barY))
                bar.addLine(to: CGPoint(x: cx + barHalf, y: barY))
                ctx.stroke(bar, with: .color(color), style: StrokeStyle(lineWidth: side * 0.025, lineCap: .round))

                // Positive swing → rightmost ball out to the right, negative → leftmost to the left.
                let swing = sin(t / period * 2 * .pi)
                let maxRad = maxAngle * .pi / 180

                for i in 0..<n {
                    var angle = 0.0
                    if i == n - 1, swing > 0 { angle = swing * maxRad }
                    if i == 0, swing < 0 { angle = swing * maxRad }

                    let pivot = CGPoint(x: cx + (CGFloat(i) - CGFloat(n - 1) / 2) * d, y: barY)
                    let ball = CGPoint(x: pivot.x + sin(angle) * length,
                                       y: pivot.y + cos(angle) * length)

                    var string = Path()
                    string.move(to: pivot)
                    string.addLine(to: ball)
                    ctx.stroke(string, with: .color(color.opacity(0.7)), lineWidth: max(side * 0.012, 0.5))
                    ctx.fill(Path(ellipseIn: CGRect(x: ball.x - d / 2, y: ball.y - d / 2, width: d, height: d)),
                             with: .color(color))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("NewtonCradle") {
    SpinnerPreviewStage(name: "NewtonCradle") {
        NewtonCradle().frame(width: 100, height: 100)
        HStack(spacing: 32) {
            NewtonCradle(color: .cyan, ballCount: 4).frame(width: 48, height: 48)
            NewtonCradle(color: .orange, period: 1.0).frame(width: 48, height: 48)
        }
    }
}
