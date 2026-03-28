// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Nook",
    platforms: [
        .macOS(.v13),
    ],
    products: [
        .library(
            name: "NookKit",
            targets: ["NookKit"]
        ),
        .executable(
            name: "Nook",
            targets: ["NookApp"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/simibac/ConfettiSwiftUI.git", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "NookKit"
        ),
        .executableTarget(
            name: "NookApp",
            dependencies: ["NookKit", "ConfettiSwiftUI"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "NookKitTests",
            dependencies: ["NookKit"]
        ),
        .testTarget(
            name: "NookAppTests",
            dependencies: ["NookApp", "NookKit"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
