//
//  ContentView.swift
//  SpinnerCollection
//
//  Created by karmic on 10/21/26.
//

import SwiftUI

/// A spinner's tint as hue / saturation / brightness, so the color slider can change
/// the hue while keeping the original saturation and brightness.
struct SpinnerTint {
    var hue: Double
    var saturation: Double
    var brightness: Double

    func color(hue: Double? = nil) -> Color {
        Color(hue: hue ?? self.hue, saturation: saturation, brightness: brightness)
    }

    // The palette from the video (same values as SpinnerPalette, in HSB).
    static let violet = SpinnerTint(hue: 0.684, saturation: 0.621, brightness: 0.95)
    static let pink = SpinnerTint(hue: 0.931, saturation: 0.531, brightness: 0.96)
    static let teal = SpinnerTint(hue: 0.448, saturation: 0.784, brightness: 0.74)
    static let cyan = SpinnerTint(hue: 0.543, saturation: 0.905, brightness: 0.95)
    static let amber = SpinnerTint(hue: 0.116, saturation: 0.838, brightness: 0.99)
    static let green = SpinnerTint(hue: 0.303, saturation: 0.55, brightness: 0.784)
    static let dough = SpinnerTint(hue: 0.095, saturation: 0.575, brightness: 0.886)
}

/// One entry in the gallery. `make` builds the spinner in any color.
struct SpinnerItem: Identifiable {
    let name: String
    let tint: SpinnerTint
    /// Seconds for one full animation cycle with the spinner's default settings.
    /// Cycles start at whole multiples of this on the shared clock, which is what
    /// lets "Cycle colors" switch exactly when the animation wraps around.
    let cycle: Double
    let make: (Color) -> AnyView
    var id: String { name }

    init<V: View>(_ name: String, _ tint: SpinnerTint, cycle: Double,
                  _ make: @escaping (Color) -> V) {
        self.name = name
        self.tint = tint
        self.cycle = cycle
        self.make = { AnyView(make($0)) }
    }

    /// The spinner in its original color.
    var view: AnyView { make(tint.color()) }
}

enum SpinnerGallery {
    // `cycle` values match each spinner's default period in its own file.
    static let items: [SpinnerItem] = [
        SpinnerItem("SpokeSpinner", .violet, cycle: 1.0) { SpokeSpinner(color: $0) },
        SpinnerItem("ExpressiveArc", .pink, cycle: 1.4) { ExpressiveArc(color: $0) },
        SpinnerItem("CometSpinner", .teal, cycle: 1.1) { CometSpinner(color: $0) },
        SpinnerItem("DualRing", .cyan, cycle: 1.4) { DualRing(color: $0) },
        SpinnerItem("PulseRipple", .amber, cycle: 1.6) { PulseRipple(color: $0) },

        SpinnerItem("BouncingDots", .violet, cycle: 1.2) { BouncingDots(color: $0) },
        SpinnerItem("WaveBars", .pink, cycle: 1.1) { WaveBars(color: $0) },
        SpinnerItem("GridPulse", .teal, cycle: 1.8) { GridPulse(color: $0) },
        SpinnerItem("FlippingSquare", .cyan, cycle: 2.0) { FlippingSquare(color: $0) },
        SpinnerItem("ChasingBlocks", .amber, cycle: 2.4) { ChasingBlocks(color: $0) },

        SpinnerItem("NewtonCradle", .violet, cycle: 1.4) { NewtonCradle(color: $0) },
        SpinnerItem("InfinityTrail", .pink, cycle: 2.0) { InfinityTrail(color: $0) },
        SpinnerItem("DnaHelix", .teal, cycle: 1.8) { DnaHelix(color: $0) },
        SpinnerItem("AtomOrbit", .cyan, cycle: 1.3) { AtomOrbit(color: $0) },
        SpinnerItem("HeartbeatLine", .amber, cycle: 1.6) { HeartbeatLine(color: $0) },

        // 5 shapes × 0.9 s: one full circle → … → hexagon → circle round trip.
        SpinnerItem("MorphingPolygon", .violet, cycle: 4.5) { MorphingPolygon(color: $0) },
        SpinnerItem("LiquidFill", .pink, cycle: 4.0) { LiquidFill(color: $0) },
        SpinnerItem("ClockSpinner", .teal, cycle: 1.2) { ClockSpinner(color: $0) },
        SpinnerItem("BouncingBall", .cyan, cycle: 0.9) { BouncingBall(color: $0) },
        SpinnerItem("StripedBar", .amber, cycle: 0.6) { StripedBar(color: $0) },

        // Illustrated spinners.
        SpinnerItem("ChemicalReaction", .teal, cycle: 1.43) { ChemicalReaction(color: $0) },
        SpinnerItem("ThunderCloud", .cyan, cycle: 2.4) { ThunderCloud(color: $0) },
        SpinnerItem("Seedling", .green, cycle: 4.5) { Seedling(color: $0) },
        SpinnerItem("PancakeBatter", .amber, cycle: 2.1) { PancakeBatter(color: $0) },
        SpinnerItem("MeltingIceCream", .pink, cycle: 5.5) { MeltingIceCream(color: $0) },
        SpinnerItem("CookieBites", .dough, cycle: 6) { CookieBites(color: $0) },
        SpinnerItem("FriedEgg", .amber, cycle: 5) { FriedEgg(color: $0) },
        SpinnerItem("Tumbleweed", .dough, cycle: 3.2) { Tumbleweed(color: $0) },
    ]
}

/// Fills the whole screen with every spinner: 4 columns in portrait, 5 in landscape,
/// with as many rows as needed. Every cell grows with the available space.
struct ContentView: View {
    private let items = SpinnerGallery.items
    private let padding: CGFloat = 12

    var body: some View {
        NavigationStack {
            grid
                .navigationDestination(for: String.self) { name in
                    if let item = items.first(where: { $0.name == name }) {
                        SpinnerDetailView(item: item)
                    }
                }
        }
        .preferredColorScheme(.dark)
    }

    private var grid: some View {
        GeometryReader { geo in
            let columns = geo.size.width > geo.size.height ? 5 : 4
            let rows = Int((Double(items.count) / Double(columns)).rounded(.up))
            let cellWidth = (geo.size.width - padding * 2) / CGFloat(columns)
            let cellHeight = (geo.size.height - padding * 2) / CGFloat(rows)
            let labelSize = max(9, min(cellWidth, cellHeight) * 0.085)

            VStack(spacing: 0) {
                ForEach(0..<rows, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<columns, id: \.self) { column in
                            let index = row * columns + column
                            if index < items.count {
                                cell(items[index], width: cellWidth, height: cellHeight, labelSize: labelSize)
                            } else {
                                Color.clear.frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
            }
            .padding(padding)
        }
        .background(SpinnerPalette.background.ignoresSafeArea())
        .toolbar(.hidden)
    }

    private func cell(_ item: SpinnerItem, width: CGFloat, height: CGFloat, labelSize: CGFloat) -> some View {
        NavigationLink(value: item.name) {
            cellContent(item, width: width, height: height, labelSize: labelSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(item.name)
        .accessibilityHint("Shows this spinner on its own")
    }

    private func cellContent(_ item: SpinnerItem, width: CGFloat, height: CGFloat, labelSize: CGFloat) -> some View {
        VStack(spacing: height * 0.08) {
            // Square spinners take the smaller side; wide ones (helix, bar…) stretch across.
            item.view
                .frame(maxWidth: width * 0.78, maxHeight: height * 0.55)
            Text(item.name)
                .font(.system(size: labelSize, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .padding(.horizontal, 4)
        }
        .frame(width: width, height: height)
        .contentShape(Rectangle())   // the whole cell is tappable, not just the drawn pixels
    }
}

/// Draws a spinner either in one color or filled with a two-color gradient.
///
/// Every spinner is drawn in a single color with varying opacity, so the gradient
/// version renders the spinner in white and uses it as a stencil (mask) for the
/// gradient: fades and transparency carry over exactly. Both copies are driven by
/// the same clock, so they stay perfectly in sync.
struct TintedSpinner: View {
    let item: SpinnerItem
    let start: Color
    /// nil → solid `start` color.
    let end: Color?

    var body: some View {
        if let end {
            item.make(.clear)     // invisible copy that gives the overlay its size
                .overlay {
                    LinearGradient(colors: [start, end],
                                   startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(item.make(.white))
                }
        } else {
            item.make(start)
        }
    }
}

/// Full-screen view of one spinner with color controls on top,
/// plus a row showing it at everyday sizes.
struct SpinnerDetailView: View {
    let item: SpinnerItem
    @State private var hue: Double
    @State private var gradientOn = false
    @State private var endHue: Double
    @State private var cycleColors = false
    /// Animation time when "Cycle colors" was (re)started.
    @State private var cycleStart: TimeInterval = 0
    /// Speed slider position: −1 … 0 … 1 ↔ 0.25× … 1× … 4× (logarithmic, so the
    /// middle is the original speed and both halves feel equally sensitive).
    @State private var speedLevel: Double = 0
    @State private var timeScale = SpinnerTimeScale()

    private var speed: Double { pow(4, speedLevel) }

    /// "Now" in animation time (follows the speed slider).
    private var animationNow: TimeInterval {
        timeScale.scaled(Date.now.timeIntervalSinceReferenceDate)
    }

    /// Slider binding that re-anchors the clock so speed changes never make the animation jump.
    private var speedBinding: Binding<Double> {
        Binding(
            get: { speedLevel },
            set: { newValue in
                // Snap to exactly 1× near the middle.
                let level = abs(newValue) < 0.04 ? 0 : newValue
                speedLevel = level
                timeScale = timeScale.withSpeed(pow(4, level),
                                                at: Date.now.timeIntervalSinceReferenceDate)
            }
        )
    }

    /// How far round the color wheel the hue glides during one animation cycle
    /// (30° → a full rainbow every 12 cycles).
    private let hueStep = 1.0 / 12

    init(item: SpinnerItem) {
        self.item = item
        _hue = State(initialValue: item.tint.hue)
        // Start the second color a little further round the color wheel.
        let next = item.tint.hue + 0.18
        _endHue = State(initialValue: next > 1 ? next - 1 : next)
    }

    /// The hue offset at time `t`. It glides continuously, in step with the animation:
    /// exactly one `hueStep` per animation cycle, starting from 0 when switched on and
    /// wrapping round the full color wheel. No jumps, so color and motion feel like one.
    private func hueShift(at t: TimeInterval) -> Double {
        guard cycleColors else { return 0 }
        let cycles = max(t - cycleStart, 0) / item.cycle
        return SpinnerMath.frac(cycles * hueStep)
    }

    /// Folds the current cycling offset into the stored hues and restarts the cycle clock
    /// from now. Colors stay exactly where they are on screen, but the sliders' stored
    /// values now match what is shown, so dragging or switching off never causes a jump.
    private func bakeShift() {
        guard cycleColors else { return }
        let now = animationNow
        let shift = hueShift(at: now)
        hue = SpinnerMath.frac(hue + shift)
        endHue = SpinnerMath.frac(endHue + shift)
        cycleStart = now
    }

    /// Toggle binding that bakes the offset in before cycling stops, so the
    /// spinner and sliders stay on the color they had reached.
    private var cycleBinding: Binding<Bool> {
        Binding(
            get: { cycleColors },
            set: { isOn in
                if isOn {
                    cycleStart = animationNow
                } else {
                    bakeShift()
                }
                cycleColors = isOn
            }
        )
    }

    /// The spinner colored for time `t` (solid or gradient, shifted when cycling).
    private func spinner(at t: TimeInterval) -> TintedSpinner {
        let shift = hueShift(at: t)
        return TintedSpinner(
            item: item,
            start: item.tint.color(hue: SpinnerMath.frac(hue + shift)),
            end: gradientOn ? item.tint.color(hue: SpinnerMath.frac(endHue + shift)) : nil
        )
    }

    var body: some View {
        GeometryReader { geo in
            let big = min(geo.size.width, geo.size.height) * 0.55

            VStack(spacing: 0) {
                controls
                    .frame(maxWidth: 420)
                    .padding(.horizontal, 24)
                    .padding(.top, 16)

                Spacer()
                SpinnerClock { t in spinner(at: t) }
                    .frame(maxWidth: big, maxHeight: big)
                Spacer()

                // How it looks at real UI sizes.
                HStack(alignment: .bottom, spacing: 32) {
                    ForEach([20, 32, 48, 64], id: \.self) { size in
                        VStack(spacing: 8) {
                            SpinnerClock { t in spinner(at: t) }
                                .frame(maxWidth: CGFloat(size) * 2, maxHeight: CGFloat(size))
                            Text("\(size) pt")
                                .font(.caption2)
                                .foregroundStyle(.white.opacity(0.45))
                        }
                    }
                }
                .padding(.bottom, 40)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        // Every SpinnerClock in here (spinners, sliders, color cycling) runs at this speed.
        .environment(\.spinnerTimeScale, timeScale)
        .background(SpinnerPalette.background.ignoresSafeArea())
        .navigationTitle(item.name)
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private var controls: some View {
        VStack(spacing: 14) {
            // The sliders run on the same clock as the spinner, so while
            // "Cycle colors" is on their handles glide along with the color.
            sliderRow(gradientOn ? "Start" : "Color") {
                SpinnerClock { t in
                    HueSlider(hue: $hue, tint: item.tint,
                              shift: hueShift(at: t), onEdit: bakeShift)
                }
            }

            Toggle("Gradient", isOn: $gradientOn.animation(.easeInOut(duration: 0.25)))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .tint(item.tint.color(hue: hue))

            if gradientOn {
                sliderRow("End") {
                    SpinnerClock { t in
                        HueSlider(hue: $endHue, tint: item.tint,
                                  shift: hueShift(at: t), onEdit: bakeShift)
                    }
                    .accessibilityLabel("Gradient end color")
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            Toggle("Cycle colors", isOn: cycleBinding)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.8))
                .tint(item.tint.color(hue: hue))
                .accessibilityHint("Slowly moves the color round the color wheel in time with the animation")

            speedRow
        }
    }

    private var speedRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Speed")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
                Spacer()
                // Tap the value to go back to the original speed.
                Button {
                    speedBinding.wrappedValue = 0
                } label: {
                    Text(String(format: "%.2f×", speed))
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(.white.opacity(speedLevel == 0 ? 0.5 : 0.9))
                }
                .buttonStyle(.plain)
                .disabled(speedLevel == 0)
                .accessibilityLabel("Reset speed")
            }

            HStack(spacing: 10) {
                Image(systemName: "tortoise.fill")
                    .foregroundStyle(.white.opacity(0.5))
                Slider(value: speedBinding, in: -1...1)
                    .tint(item.tint.color(hue: hue))
                    .accessibilityLabel("Animation speed")
                    .accessibilityValue(String(format: "%.2f times", speed))
                Image(systemName: "hare.fill")
                    .foregroundStyle(.white.opacity(0.5))
            }
            .font(.footnote)
        }
    }

    private func sliderRow<S: View>(_ title: String, @ViewBuilder slider: () -> S) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.medium))
                .foregroundStyle(.white.opacity(0.5))
            slider()
        }
    }
}

/// A rainbow track with a draggable thumb. Drag or tap anywhere on it to pick a hue.
struct HueSlider: View {
    @Binding var hue: Double
    let tint: SpinnerTint
    /// Extra offset added for display (used while colors are cycling).
    var shift: Double = 0
    /// Called just before the user changes the value, so the owner can fold `shift` into `hue`.
    var onEdit: () -> Void = {}

    private let thumb: CGFloat = 30
    private let trackHeight: CGFloat = 14

    /// The hue actually shown, wrapped round the color wheel.
    private var shown: Double { shift == 0 ? hue : SpinnerMath.frac(hue + shift) }

    var body: some View {
        let hue = shown

        GeometryReader { geo in
            let travel = max(geo.size.width - thumb, 1)
            let rainbow = stride(from: 0.0, through: 1.0, by: 1.0 / 12).map { tint.color(hue: $0) }

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(LinearGradient(colors: rainbow, startPoint: .leading, endPoint: .trailing))
                    .frame(height: trackHeight)
                    .padding(.horizontal, thumb / 2 - trackHeight / 2)

                Circle()
                    .fill(tint.color(hue: hue))
                    .overlay(Circle().stroke(.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.4), radius: 4, y: 2)
                    .frame(width: thumb, height: thumb)
                    .offset(x: CGFloat(hue) * travel)
            }
            .frame(height: geo.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        onEdit()
                        self.hue = min(max(Double((value.location.x - thumb / 2) / travel), 0), 1)
                    }
            )
        }
        .frame(height: thumb + 8)
        .accessibilityElement()
        .accessibilityLabel("Color")
        .accessibilityValue("Hue \(Int(hue * 360)) degrees")
        .accessibilityAdjustableAction { direction in
            onEdit()
            switch direction {
            case .increment: self.hue = min(hue + 0.05, 1)
            case .decrement: self.hue = max(hue - 0.05, 0)
            @unknown default: break
            }
        }
    }
}

#Preview {
    ContentView()
}

#Preview("Detail") {
    NavigationStack {
        SpinnerDetailView(item: SpinnerGallery.items[0])
    }
    .preferredColorScheme(.dark)
}
