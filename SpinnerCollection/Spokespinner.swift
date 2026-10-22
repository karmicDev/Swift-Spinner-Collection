//
//  Spokespinner.swift
//  SpinnerCollection
//
//  Created by karmic on 10/21/26.
//

import SwiftUI
 
/// A classic spoke "activity" spinner: a ring of rounded bars whose opacity
/// steps clockwise, leaving a fading tail behind the brightest spoke.
///
/// Usage:
///     SpokeSpinner()
///     SpokeSpinner(color: .mint, spokeCount: 8, period: 0.8)
///         .frame(width: 32, height: 32)
public struct SpokeSpinner: View {
    var color: Color
    var spokeCount: Int
    /// Seconds for one full revolution of the bright spoke.
    var period: Double
    /// Opacity of the dimmest spoke (the very end of the tail).
    var minOpacity: Double
    /// Spoke length as a fraction of the radius (0...1).
    var spokeLength: CGFloat
    /// Spoke thickness as a fraction of the view's size.
    var spokeWidth: CGFloat
    /// Step from spoke to spoke (classic look) or rotate smoothly.
    var stepped: Bool
 
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.spinnerTimeScale) private var timeScale
 
    public init(
        color: Color = Color(red: 0.42, green: 0.36, blue: 0.95),
        spokeCount: Int = 12,
        period: Double = 1.0,
        minOpacity: Double = 0.2,
        spokeLength: CGFloat = 0.45,
        spokeWidth: CGFloat = 0.085,
        stepped: Bool = true
    ) {
        self.color = color
        self.spokeCount = max(spokeCount, 3)
        self.period = max(period, 0.1)
        self.minOpacity = minOpacity
        self.spokeLength = spokeLength
        self.spokeWidth = spokeWidth
        self.stepped = stepped
    }
 
    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            Canvas { ctx, size in
                let side = min(size.width, size.height)
                let radius = side / 2
                let center = CGPoint(x: size.width / 2, y: size.height / 2)
                let length = radius * spokeLength
                let width = side * spokeWidth
                let inner = radius - length
 
                // Position of the "head" spoke, in spokes (0..<spokeCount).
                let t = timeScale.scaled(context.date.timeIntervalSinceReferenceDate)
                let progress = (t / period).truncatingRemainder(dividingBy: 1)
                var head = progress * Double(spokeCount)
                if stepped { head.round(.down) }
 
                for i in 0..<spokeCount {
                    // How many spokes behind the head this one is (0 = head).
                    var behind = head - Double(i)
                    behind = behind.truncatingRemainder(dividingBy: Double(spokeCount))
                    if behind < 0 { behind += Double(spokeCount) }
                    let fade = 1 - behind / Double(spokeCount)
                    let opacity = minOpacity + (1 - minOpacity) * fade
 
                    // Spoke 0 points straight up; indices increase clockwise.
                    let angle = Angle.degrees(Double(i) / Double(spokeCount) * 360 - 90)
                    let dir = CGPoint(x: cos(angle.radians), y: sin(angle.radians))
                    let start = CGPoint(x: center.x + dir.x * (inner + width / 2),
                                        y: center.y + dir.y * (inner + width / 2))
                    let end = CGPoint(x: center.x + dir.x * (radius - width / 2),
                                      y: center.y + dir.y * (radius - width / 2))
 
                    var path = Path()
                    path.move(to: start)
                    path.addLine(to: end)
                    ctx.stroke(path,
                               with: .color(color.opacity(opacity)),
                               style: StrokeStyle(lineWidth: width, lineCap: .round))
                }
            }
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityElement()
        .accessibilityLabel("Loading")
        .accessibilityAddTraits(.updatesFrequently)
    }
}
 
#Preview("SpokeSpinner") {
    ZStack {
        Color(red: 0.07, green: 0.07, blue: 0.09).ignoresSafeArea()
        VStack(spacing: 40) {
            SpokeSpinner()
                .frame(width: 80, height: 80)
            Text("SpokeSpinner")
                .font(.footnote)
                .foregroundStyle(.white.opacity(0.7))
 
            HStack(spacing: 32) {
                SpokeSpinner(color: .pink, spokeCount: 8, period: 0.8)
                    .frame(width: 36, height: 36)
                SpokeSpinner(color: .mint, stepped: false)
                    .frame(width: 36, height: 36)
                SpokeSpinner(color: .orange, spokeCount: 16, period: 1.4,
                             spokeLength: 0.3, spokeWidth: 0.06)
                    .frame(width: 36, height: 36)
            }
        }
    }
}
