//
//  WaveBars.swift
//  SpinnerCollection
//

import SwiftUI

/// A row of rounded bars whose heights ripple like an audio equalizer.
struct WaveBars: View {
    var color: Color = SpinnerPalette.pink
    var barCount: Int = 7
    /// Seconds for the wave to travel once across the bars.
    var period: Double = 1.1
    /// Shortest bar height as a fraction of the tallest.
    var minHeight: Double = 0.35

    var body: some View {
        SpinnerClock { t in
            Canvas { ctx, size in
                let n = max(barCount, 1)
                let side = min(size.width, size.height)
                let maxH = side * 0.8
                let slot = side * 0.9 / CGFloat(n)
                let barW = slot * 0.55
                let startX = (size.width - slot * CGFloat(n)) / 2 + (slot - barW) / 2
                let midY = size.height / 2

                for i in 0..<n {
                    let phase = t / period * 2 * .pi - Double(i) * 0.9
                    let level = minHeight + (1 - minHeight) * (0.5 + 0.5 * sin(phase))
                    let h = maxH * level
                    let rect = CGRect(x: startX + CGFloat(i) * slot, y: midY - h / 2,
                                      width: barW, height: h)
                    ctx.fill(Path(roundedRect: rect, cornerRadius: barW / 2), with: .color(color))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .spinnerAccessibility()
    }
}

#Preview("WaveBars") {
    SpinnerPreviewStage(name: "WaveBars") {
        WaveBars().frame(width: 80, height: 80)
        HStack(spacing: 32) {
            WaveBars(color: .cyan, barCount: 5).frame(width: 36, height: 36)
            WaveBars(color: .orange, period: 0.7).frame(width: 36, height: 36)
        }
    }
}
