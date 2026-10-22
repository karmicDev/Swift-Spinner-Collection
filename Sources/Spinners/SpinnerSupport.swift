//
//  SpinnerSupport.swift
//  Spinners
//
//  Shared palette, clock and helpers used by the spinners.
//

import SwiftUI

/// The default colors of the spinners.
public enum SpinnerPalette {
    public static let violet = Color(red: 0.42, green: 0.36, blue: 0.95)
    public static let pink = Color(red: 0.96, green: 0.45, blue: 0.66)
    public static let teal = Color(red: 0.16, green: 0.74, blue: 0.56)
    public static let cyan = Color(red: 0.09, green: 0.73, blue: 0.95)
    public static let amber = Color(red: 0.99, green: 0.74, blue: 0.16)
    public static let green = Color(red: 0.431, green: 0.784, blue: 0.353)
    public static let dough = Color(red: 0.886, green: 0.667, blue: 0.376)
    public static let background = Color(red: 0.07, green: 0.07, blue: 0.09)
}

extension GraphicsContext {
    /// Scales drawing so a `design` × `design` point square fills the middle of `size`.
    /// Lets the illustrated spinners be drawn in fixed design coordinates at any size.
    mutating func fitSquare(_ size: CGSize, design: CGFloat) {
        let side = min(size.width, size.height)
        translateBy(x: (size.width - side) / 2, y: (size.height - side) / 2)
        scaleBy(x: side / design, y: side / design)
    }
}

extension Path {
    static func circle(_ center: CGPoint, _ radius: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - radius, y: center.y - radius,
                               width: radius * 2, height: radius * 2))
    }

    static func ellipse(_ center: CGPoint, _ rx: CGFloat, _ ry: CGFloat) -> Path {
        Path(ellipseIn: CGRect(x: center.x - rx, y: center.y - ry, width: rx * 2, height: ry * 2))
    }
}

/// Maps real time to animation time, so animations can run faster or slower.
///
/// Animation time = `anchorScaled + (real − anchorReal) × speed`. Changing speed
/// re-anchors at the current moment, so the animation continues from exactly where
/// it is instead of jumping.
public nonisolated struct SpinnerTimeScale: Equatable, Sendable {
    public var anchorReal: TimeInterval
    public var anchorScaled: TimeInterval
    public var speed: Double

    /// `speed` 1 is normal, 2 twice as fast, 0.5 half as fast.
    public init(anchorReal: TimeInterval = 0, anchorScaled: TimeInterval = 0, speed: Double = 1) {
        self.anchorReal = anchorReal
        self.anchorScaled = anchorScaled
        self.speed = speed
    }

    public func scaled(_ real: TimeInterval) -> TimeInterval {
        anchorScaled + (real - anchorReal) * speed
    }

    /// A copy running at `newSpeed` that continues smoothly from `real`.
    public func withSpeed(_ newSpeed: Double, at real: TimeInterval) -> SpinnerTimeScale {
        SpinnerTimeScale(anchorReal: real, anchorScaled: scaled(real), speed: newSpeed)
    }
}

extension EnvironmentValues {
    /// Speed control for every `SpinnerClock` below this point in the view tree.
    @Entry public var spinnerTimeScale = SpinnerTimeScale()
}

/// Re-renders its content every frame with the current animation time in seconds.
/// Follows `spinnerTimeScale` from the environment, and pauses (shows a still frame)
/// when Reduce Motion is on.
public struct SpinnerClock<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.spinnerTimeScale) private var timeScale
    private let content: (TimeInterval) -> Content

    public init(@ViewBuilder content: @escaping (TimeInterval) -> Content) {
        self.content = content
    }

    public var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            content(timeScale.scaled(context.date.timeIntervalSinceReferenceDate))
        }
    }
}

/// Small math helpers used by the spinners (handy for writing your own).
public enum SpinnerMath {
    /// Fractional part, always in 0..<1.
    public static func frac(_ x: Double) -> Double { x - x.rounded(.down) }

    /// Ease-in-out cubic.
    public static func ease(_ x: Double) -> Double {
        let x = min(max(x, 0), 1)
        return x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2
    }

    public static func lerp(_ a: Double, _ b: Double, _ t: Double) -> Double { a + (b - a) * t }

    public static func clamp(_ x: Double) -> Double { min(max(x, 0), 1) }

    /// Repeatable pseudo-random number in 0..<1 for a given seed.
    public static func rnd(_ seed: Double) -> Double { frac(sin(seed * 127.1) * 43758.5453) }

    public static func lerp(_ a: CGPoint, _ b: CGPoint, _ t: Double) -> CGPoint {
        CGPoint(x: a.x + (b.x - a.x) * t, y: a.y + (b.y - a.y) * t)
    }
}

extension View {
    /// VoiceOver reads every spinner as a single "Loading" element.
    func spinnerAccessibility() -> some View {
        accessibilityElement()
            .accessibilityLabel("Loading")
            .accessibilityAddTraits(.updatesFrequently)
    }
}

/// Dark stage used by every #Preview.
struct SpinnerPreviewStage<Content: View>: View {
    let name: String
    @ViewBuilder var content: Content

    var body: some View {
        ZStack {
            SpinnerPalette.background.ignoresSafeArea()
            VStack(spacing: 24) {
                content
                Text(name)
                    .font(.footnote)
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding()
        }
    }
}
