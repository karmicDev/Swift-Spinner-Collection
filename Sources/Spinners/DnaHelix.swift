//
//  DnaHelix.swift
//  Spinners
//

import SwiftUI

/// Two dotted strands twisting around each other, joined by faint rungs.
/// Dots grow and brighten as they swing toward the viewer.
public struct DnaHelix: View {
    var color: Color = SpinnerPalette.teal
    var dotCount: Int = 16
    /// Number of full twists visible across the width.
    var turns: Double = 1.5
    /// Seconds per full twist.
    var period: Double = 1.8


    public init(
        color: Color = SpinnerPalette.teal,
        dotCount: Int = 16,
        turns: Double = 1.5,
        period: Double = 1.8
    ) {
        self.color = color
        self.dotCount = dotCount
        self.turns = turns
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let n = max(dotCount, 2)
                let amplitude = size.height * 0.36
                let maxDot = min(size.height * 0.11, size.width / CGFloat(n) * 0.8)
                let step = (size.width - maxDot) / CGFloat(n - 1)
                let midY = size.height / 2
                let spin = t / period * 2 * .pi

                for i in 0..<n {
                    let x = maxDot / 2 + CGFloat(i) * step
                    let phi = Double(i) / Double(n - 1) * turns * 2 * .pi - spin
                    let yA = midY + amplitude * sin(phi)
                    let yB = midY - amplitude * sin(phi)
                    let depthA = (1 + cos(phi)) / 2       // 1 = closest to viewer
                    let depthB = 1 - depthA

                    var rung = Path()
                    rung.move(to: CGPoint(x: x, y: yA))
                    rung.addLine(to: CGPoint(x: x, y: yB))
                    ctx.stroke(rung, with: .color(color.opacity(0.15)), lineWidth: max(maxDot * 0.15, 0.5))

                    for (y, depth) in [(yA, depthA), (yB, depthB)] {
                        let d = maxDot * (0.45 + 0.55 * depth)
                        ctx.fill(Path(ellipseIn: CGRect(x: x - d / 2, y: y - d / 2, width: d, height: d)),
                                 with: .color(color.opacity(0.3 + 0.7 * depth)))
                    }
                }
            }
        }
        .aspectRatio(2, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("DnaHelix") {
    SpinnerPreviewStage(name: "DnaHelix") {
        DnaHelix().frame(width: 160, height: 80)
        HStack(spacing: 32) {
            DnaHelix(color: .pink, dotCount: 10, turns: 1).frame(width: 72, height: 36)
            DnaHelix(color: .cyan, period: 1.0).frame(width: 72, height: 36)
        }
    }
}
