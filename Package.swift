// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NSDK",
    platforms: [
      .iOS(.v15),  // Minimum iOS version supported by NSDK
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "NSDK",
            type: .dynamic,
            targets: ["NSDK"]
        )
    ],
    dependencies: [
        // Keep in lockstep with protoc-gen-swift in MODULE.bazel
        // (@com_github_apple_swift_protobuf version). Generated .pb.swift requires
        // a runtime >= the generator version.
        .package(url: "https://github.com/apple/swift-protobuf.git", from: "1.38.1"),
    ],
    targets: [
        .target(
            name: "NSDK",
            dependencies: [
                "CArdk",
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
            ],
            resources: [
                .process("Playback/PlaybackShaders.metal")
            ]
        ),
        // MARK: - Binary dependency
        .binaryTarget(
            name: "CArdk",
            path: "CArdk.xcframework"
        )
    ]
)
