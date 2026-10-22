//
//  ExpressiveArc.swift
//  Spinners
//
//  Created by karmic on 10/21/26.
//

import SwiftUI

/// A Material-style indeterminate arc: the arc's head races ahead until it is
/// almost a full ring, then its tail catches up until only a short dash is left,
/// all while the whole thing keeps rotating clockwise.
///
/// Usage:
///     ExpressiveArc()
///     ExpressiveArc(color: .cyan, lineWidth: 0.08, cycleDuration: 1.0)
///         .frame(width: 32, height: 32)
public struct ExpressiveArc: View {
    var color: Color
    /// Stroke thickness as a fraction of the view's size.
    var lineWidth: CGFloat
    /// Seconds for one grow + shrink cycle.
    var cycleDuration: Double
    /// Seconds for one full turn of the base rotation.
    var rotationDuration: Double
    /// Shortest and longest arc, in degrees.
    var minSweep: Double
    var maxSweep: Double

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.spinnerTimeScale) private var timeScale

    public init(
        color: Color = Color(red: 0.96, green: 0.45, blue: 0.66),
        lineWidth: CGFloat = 0.1,
        cycleDuration: Double = 1.4,
        rotationDuration: Double = 2.0,
        minSweep: Double = 12,
        maxSweep: Double = 280
    ) {
        self.color = color
        self.lineWidth = lineWidth
        self.cycleDuration = max(cycleDuration, 0.2)
        self.rotationDuration = max(rotationDuration, 0.2)
        self.minSweep = minSweep
        self.maxSweep = max(maxSweep, minSweep)
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            Canvas { ctx, size in
                let t = timeScale.scaled(context.date.timeIntervalSinceReferenceDate)
                let (tail, head) = arcEnds(at: t)

                let side = min(size.width, size.height)
                let stroke = side * lineWidth
                let radius = (side - stroke) / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                var path = Path()
                // -90° so 0 is at 12 o'clock; SwiftUI angles run clockwise on screen.
                path.addArc(center: center,
                            radius: radius,
                            startAngle: .degrees(tail - 90),
                            endAngle: .degrees(head - 90),
                            clockwise: false)
                ctx.stroke(path,
                           with: .color(color),
                           style: StrokeStyle(lineWidth: stroke, lineCap: .round))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }

    /// Tail and head angles in degrees (head > tail) at time `t`.
    private func arcEnds(at t: TimeInterval) -> (Double, Double) {
        let jump = maxSweep - minSweep           // how far the tail advances per cycle
        let cycles = t / cycleDuration
        let n = cycles.rounded(.down)
        let f = cycles - n                       // 0..<1 within the current cycle
        let base = (n * jump).truncatingRemainder(dividingBy: 360)
            + (t / rotationDuration).truncatingRemainder(dividingBy: 1) * 360

        if f < 0.5 {
            // Grow: tail holds, head eases forward.
            let e = Self.ease(f / 0.5)
            return (base, base + minSweep + jump * e)
        } else {
            // Shrink: head holds, tail eases forward to catch up.
            let e = Self.ease((f - 0.5) / 0.5)
            return (base + jump * e, base + maxSweep)
        }
    }

    /// Ease-in-out cubic: slow start, fast middle, slow finish.
    private static func ease(_ x: Double) -> Double {
        x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }
}

#Preview("ExpressiveArc") {
    ZStack {
        Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()
        VStack(spacing: 40) {
            ExpressiveArc()
                .frame(width: 80, height: 80)
            Text("ExpressiveArc")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 32) {
                ExpressiveArc(color: .cyan, lineWidth: 0.08, cycleDuration: 1.0)
                    .frame(width: 36, height: 36)
                ExpressiveArc(color: .mint, lineWidth: 0.14)
                    .frame(width: 36, height: 36)
                ExpressiveArc(color: .orange, cycleDuration: 2.0, maxSweep: 320)
                    .frame(width: 36, height: 36)
            }
        }
    }
}
