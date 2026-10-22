// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "SpinnerCollection",
    platforms: [
        .iOS(.v18),
        .macOS(.v15),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "Spinners", targets: ["Spinners"]),
    ],
    targets: [
        .target(
            name: "Spinners",
            swiftSettings: [
                // Views are UI code: isolate everything to the main actor by default,
                // matching the settings the spinners were written with.
                .defaultIsolation(MainActor.self),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
