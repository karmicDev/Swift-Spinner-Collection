//
//  GradientSpinner.swift
//  Spinners
//

import SwiftUI

/// Fills any spinner with a linear gradient instead of a single color.
///
/// Every spinner is drawn in one color with varying opacity, so drawing it in white and
/// using it as a mask keeps all of its fades and transparency. Both copies run on the
/// same clock, so they stay perfectly in sync.
///
///     GradientSpinner(colors: [.pink, .orange]) { CometSpinner(color: $0) }
///         .frame(width: 48, height: 48)
public struct GradientSpinner<Spinner: View>: View {
    private let colors: [Color]
    private let startPoint: UnitPoint
    private let endPoint: UnitPoint
    private let spinner: (Color) -> Spinner

    /// - Parameters:
    ///   - colors: The gradient colors, from `startPoint` to `endPoint`.
    ///   - spinner: Builds the spinner in the color it is given.
    public init(
        colors: [Color],
        startPoint: UnitPoint = .topLeading,
        endPoint: UnitPoint = .bottomTrailing,
        @ViewBuilder spinner: @escaping (Color) -> Spinner
    ) {
        self.colors = colors
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.spinner = spinner
    }

    public var body: some View {
        spinner(.clear)   // invisible copy that gives the gradient its size
            .overlay {
                LinearGradient(colors: colors, startPoint: startPoint, endPoint: endPoint)
                    .mask(spinner(.white))
            }
    }
}

#Preview("GradientSpinner") {
    SpinnerPreviewStage(name: "GradientSpinner") {
        GradientSpinner(colors: [.pink, .orange]) { CometSpinner(color: $0) }
            .frame(width: 80, height: 80)
        GradientSpinner(colors: [.cyan, .purple]) { MeltingIceCream(color: $0) }
            .frame(width: 80, height: 80)
    }
}
