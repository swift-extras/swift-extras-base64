// swift-tools-version:6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-extras-base64",
    products: [
        .library(name: "ExtrasBase64", targets: ["ExtrasBase64"])
    ],
    dependencies: [],
    targets: [
        .target(name: "ExtrasBase64", dependencies: [], swiftSettings: swiftSettings),
        .testTarget(name: "ExtrasBase64Tests", dependencies: ["ExtrasBase64"]),
    ],
    swiftLanguageModes: [.v6]
)

var swiftSettings: [SwiftSetting] {
    [
        // .strictMemorySafety(),
        // .treatAllWarnings(as: .error),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
        .enableExperimentalFeature("Lifetimes"),
        .enableUpcomingFeature("LifetimeDependence"),
        .enableUpcomingFeature("ImmutableWeakCaptures"),
    ]
}
