// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-extras-base64",
    products: [
        .library(name: "ExtrasBase64", targets: ["ExtrasBase64"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "ExtrasBase64", dependencies: []),
        .testTarget(name: "ExtrasBase64Tests", dependencies: ["ExtrasBase64"]),
    ]
)
