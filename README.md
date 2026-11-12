# NSDK for iOS

The Niantic Spatial SDK (NSDK) for iOS, distributed as a Swift package wrapping the
`CArdk` XCFramework. It provides native integration for AR features such as meshing,
occlusion, object detection, localization, and more.

## Quick Links
* [NSDK API Reference](https://www.nianticspatial.com/docs/api/swift/)
* [Documentation](https://www.nianticspatial.com/docs/nsdk/?platform=swift)
* [Niantic Spatial Platform](https://www.nianticspatial.com)

## Requirements

* iOS 15.0 or later
* Swift 6.0 toolchain (Xcode 16 or later)

## Getting Started

### Add the package in Xcode

1. In Xcode, choose **File > Add Package Dependencies…**
2. Enter the package URL: `https://github.com/nianticspatial/nsdk-library-xcframework`
3. For **Dependency Rule**, choose **Exact Version** and enter the release you want.
4. Add the `NSDK` library product to your app target.

### Or declare it in `Package.swift`

```swift
dependencies: [
    .package(url: "https://github.com/nianticspatial/nsdk-library-xcframework.git", exact: "VERSION")
]
```

Then add `NSDK` to your target's dependencies:

```swift
.target(
    name: "YourApp",
    dependencies: [
        .product(name: "NSDK", package: "NSDK")
    ]
)
```

## Versioning

Releases follow SemVer 2.0. A version containing a hyphen — for example
`4.3.0-25081200` — is a prerelease.

Use an **exact version** rather than a range. Swift Package Manager follows SemVer and
excludes prereleases from range operators, so `from: "4.3.0"` will not match a prerelease
build and resolution will fail to find it.

### Switching between versions

Xcode caches compiled modules per project. If a build fails with unexpected NSDK errors
after changing version, clean the build folder: **Product → Clean Build Folder** (⇧⌘K).

## License

See [LICENSE](LICENSE).
