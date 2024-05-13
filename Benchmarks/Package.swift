// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Benchmarks",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/ordo-one/package-benchmark.git", from: "1.0.0"),
        .package(name: "swift-extras-base64", path: ".."),
    ],
    targets: [
        .executableTarget(
            name: "BaseN",
            dependencies: [
                .product(name: "ExtrasBase64", package: "swift-extras-base64"),
                .product(name: "Benchmark", package: "package-benchmark"),
            ],
            path: "Benchmarks/BaseN",
            plugins: [
                .plugin(name: "BenchmarkPlugin", package: "package-benchmark"),
            ]
        ),
    ]
)
