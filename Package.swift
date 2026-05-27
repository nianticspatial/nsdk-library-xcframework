// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NSDK",
    platforms: [
      .iOS(.v15)  // Minimum iOS version supported by NSDK
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NSDK",
            type: .dynamic,
            targets: ["NSDK"]
        )
    ],
    targets: [
        .target(
            name: "NSDK",
            dependencies: ["CArdk"],
            resources: [
                .process("Playback/PlaybackShaders.metal")
            ]
        ),
        .testTarget(
            name: "NSDKTests",
            dependencies: ["NSDK"]
        ),
        // MARK: - Binary dependency
        .binaryTarget(
            name: "CArdk",
            path: "CArdk.xcframework"
        )
    ]
)
