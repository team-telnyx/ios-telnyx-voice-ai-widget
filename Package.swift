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
        .package(url: "https://github.com/team-telnyx/telnyx-webrtc-ios.git", branch: "feat/WEBRTC-3068")
    ],
    targets: [
        .target(
            name: "TelnyxVoiceAIWidget",
            dependencies: [
                .product(name: "telnyx-webrtc-ios", package: "telnyx-webrtc-ios")
            ],
            path: "TelnyxVoiceAIWidget/TelnyxVoiceAIWidget"
        ),
        .testTarget(
            name: "TelnyxVoiceAIWidgetTests",
            dependencies: ["TelnyxVoiceAIWidget"],
            path: "Tests"
        ),
    ]
)
