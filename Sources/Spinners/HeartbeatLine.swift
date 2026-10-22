//
//  HeartbeatLine.swift
//  Spinners
//

import SwiftUI

/// An ECG trace: a glowing dot draws a bright pulse across a faint heartbeat line.
public struct HeartbeatLine: View {
    var color: Color = SpinnerPalette.amber
    /// Seconds for the dot to cross the line.
    var period: Double = 1.6
    /// Length of the bright trail as a fraction of the width.
    var trailLength: Double = 0.3

    /// Normalized ECG shape: x in 0...1, y in -1...1 (up is positive).
    private static let keypoints: [(Double, Double)] = [
        (0.00, 0), (0.28, 0), (0.32, 0.12), (0.36, 0), (0.40, 0),
        (0.43, -0.18), (0.47, 1.0), (0.51, -0.6), (0.54, 0), (0.62, 0),
        (0.67, 0.22), (0.72, 0), (1.00, 0),
    ]

    private static func level(at x: Double) -> Double {
        let pts = keypoints
        for i in 1..<pts.count where x <= pts[i].0 {
            let (x0, y0) = pts[i - 1], (x1, y1) = pts[i]
            return y0 + (y1 - y0) * (x - x0) / max(x1 - x0, .ulpOfOne)
        }
        return 0
    }


    public init(
        color: Color = SpinnerPalette.amber,
        period: Double = 1.6,
        trailLength: Double = 0.3
    ) {
        self.color = color
        self.period = period
        self.trailLength = trailLength
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let stroke = max(min(size.height * 0.05, 3), 1)
                let dotR = stroke * 1.6
                let inset = dotR * 2
                let w = size.width - inset * 2
                let amp = size.height / 2 - inset
                let midY = size.height / 2

                func point(_ x: Double) -> CGPoint {
                    CGPoint(x: inset + w * x, y: midY - amp * Self.level(at: x))
                }

                // Faint full trace.
                var trace = Path()
                trace.move(to: point(0))
                for i in 1...100 { trace.addLine(to: point(Double(i) / 100)) }
                ctx.stroke(trace, with: .color(color.opacity(0.18)),
                           style: StrokeStyle(lineWidth: stroke, lineCap: .round, lineJoin: .round))

                // Bright trail; the head runs past the end so the trail can leave the line.
                let head = SpinnerMath.frac(t / period) * (1 + trailLength)
                let segments = 40
                for i in 0..<segments {
                    let f0 = Double(i) / Double(segments)
                    let f1 = Double(i + 1) / Double(segments)
                    let x0 = head - trailLength * (1 - f0)
                    let x1 = head - trailLength * (1 - f1)
                    guard x1 > 0, x0 < 1 else { continue }
                    var seg = Path()
                    seg.move(to: point(max(x0, 0)))
                    seg.addLine(to: point(min(x1, 1)))
                    ctx.stroke(seg, with: .color(color.opacity(f1)),
                               style: StrokeStyle(lineWidth: stroke, lineCap: .round))
                }

                // Glowing dot.
                if head <= 1 {
                    let p = point(head)
                    let glow = dotR * 2.6
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - glow / 2, y: p.y - glow / 2, width: glow, height: glow)),
                             with: .color(color.opacity(0.25)))
                    ctx.fill(Path(ellipseIn: CGRect(x: p.x - dotR, y: p.y - dotR, width: dotR * 2, height: dotR * 2)),
                             with: .color(color))
                }
            }
        }
        .aspectRatio(2.5, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("HeartbeatLine") {
    SpinnerPreviewStage(name: "HeartbeatLine") {
        HeartbeatLine().frame(width: 200, height: 80)
        HStack(spacing: 32) {
            HeartbeatLine(color: .pink, period: 1.0).frame(width: 90, height: 36)
            HeartbeatLine(color: .mint).frame(width: 90, height: 36)
        }
    }
}
