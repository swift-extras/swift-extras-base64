// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-extras-base64",
    platforms: [
        .macOS(.v11),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "ExtrasBase64", targets: ["ExtrasBase64"])
    ],
    dependencies: [],
    targets: [
        .target(name: "ExtrasBase64", dependencies: []),
        .testTarget(name: "ExtrasBase64Tests", dependencies: ["ExtrasBase64"]),
    ],
    swiftLanguageModes: [.v6]
)
