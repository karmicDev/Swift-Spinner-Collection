//
//  ChasingBlocks.swift
//  Spinners
//

import SwiftUI

/// Two small blocks chasing each other around the corners of a square,
/// tumbling a quarter turn and shrinking mid-way along each edge.
public struct ChasingBlocks: View {
    var color: Color = SpinnerPalette.amber
    /// Seconds for one block to travel all four edges.
    var period: Double = 2.4


    public init(
        color: Color = SpinnerPalette.amber,
        period: Double = 2.4
    ) {
        self.color = color
        self.period = period
    }

    public var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let c = CGPoint(x: size.width / 2, y: size.height / 2)
                let o = side * 0.3
                // Clockwise: top-left, top-right, bottom-right, bottom-left.
                let corners = [
                    CGPoint(x: c.x - o, y: c.y - o), CGPoint(x: c.x + o, y: c.y - o),
                    CGPoint(x: c.x + o, y: c.y + o), CGPoint(x: c.x - o, y: c.y + o),
                ]
                let block = side * 0.2

                for i in 0..<2 {
                    let s = t / period * 4 + Double(i) * 2      // the two blocks sit opposite
                    let edge = Int(s.rounded(.down)) % 4
                    let f = SpinnerMath.ease(SpinnerMath.frac(s))
                    let pos = SpinnerMath.lerp(corners[edge], corners[(edge + 1) % 4], f)
                    let scale = 1 - 0.4 * sin(f * .pi)
                    let b = block * scale

                    var layer = ctx
                    layer.translateBy(x: pos.x, y: pos.y)
                    layer.rotate(by: .degrees(f * 90))
                    layer.fill(Path(roundedRect: CGRect(x: -b / 2, y: -b / 2, width: b, height: b),
                                    cornerRadius: b * 0.2),
                               with: .color(color.opacity(i == 0 ? 1 : 0.6)))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("ChasingBlocks") {
    SpinnerPreviewStage(name: "ChasingBlocks") {
        ChasingBlocks().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            ChasingBlocks(color: .cyan, period: 1.6).frame(width: 36, height: 36)
            ChasingBlocks(color: .pink).frame(width: 36, height: 36)
        }
    }
}
