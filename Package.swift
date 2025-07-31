// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TelnyxVoiceAIWidget",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "TelnyxVoiceAIWidget",
            targets: ["TelnyxVoiceAIWidget"]
        ),
    ],
    dependencies: [
        // Add your dependencies here
    ],
    targets: [
        .target(
            name: "TelnyxVoiceAIWidget",
            dependencies: [],
            path: "TelnyxVoiceAIWidget/TelnyxVoiceAIWidget"
        ),
        .testTarget(
            name: "TelnyxVoiceAIWidgetTests",
            dependencies: ["TelnyxVoiceAIWidget"],
            path: "Tests"
        ),
    ]
)
