//
//  MorphingPolygon.swift
//  SpinnerCollection
//

import SwiftUI

/// A filled shape that slowly rotates while morphing
/// circle → triangle → square → pentagon → hexagon → circle …
struct MorphingPolygon: View {
    var color: Color = SpinnerPalette.violet
    /// Side counts to cycle through; 0 means a circle.
    var shapes: [Int] = [0, 3, 4, 5, 6]
    /// Seconds spent on each shape (hold + morph).
    var stepDuration: Double = 0.9
    /// Degrees per second of rotation.
    var rotationSpeed: Double = 70

    /// Distance from center to the outline at angle `theta` for a regular n-gon
    /// (n == 0 → circle), scaled so all shapes look about the same size.
    private static func radius(sides n: Int, at theta: Double) -> Double {
        guard n >= 3 else { return 1 }
        let sector = 2 * Double.pi / Double(n)
        let local = theta - sector * (theta / sector).rounded(.down)
        let r = cos(.pi / Double(n)) / cos(local - .pi / Double(n))
        // Blend toward equal area so triangles don't look tiny next to circles.
        let area = Double(n) / 2 * sin(sector)
        let scale = 1 + (sqrt(Double.pi / area) - 1) * 0.5
        return r * scale
    }

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let list = shapes.isEmpty ? [0] : shapes
                let step = t / stepDuration
                let index = Int(step.rounded(.down)) % list.count
                let from = list[index]
                let to = list[(index + 1) % list.count]
                // Hold for the first 35% of the step, then morph.
                let m = SpinnerMath.ease((SpinnerMath.frac(step) - 0.35) / 0.65)

                let side = min(size.width, size.height)
                let maxR = side * 0.36
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let rotation = SpinnerMath.frac(t * rotationSpeed / 360) * 2 * .pi - .pi / 2

                var shape = Path()
                let samples = 180
                for i in 0..<samples {
                    let theta = Double(i) / Double(samples) * 2 * .pi
                    let r = SpinnerMath.lerp(Self.radius(sides: from, at: theta),
                                             Self.radius(sides: to, at: theta), m) * maxR
                    let p = CGPoint(x: c.x + cos(theta + rotation) * r,
                                    y: c.y + sin(theta + rotation) * r)
                    if i == 0 { shape.move(to: p) } else { shape.addLine(to: p) }
                }
                shape.closeSubpath()
                ctx.fill(shape, with: .color(color))
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("MorphingPolygon") {
    SpinnerPreviewStage(name: "MorphingPolygon") {
        MorphingPolygon().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            MorphingPolygon(color: .pink, shapes: [3, 4]).frame(width: 36, height: 36)
            MorphingPolygon(color: .cyan, stepDuration: 0.5).frame(width: 36, height: 36)
        }
    }
}
