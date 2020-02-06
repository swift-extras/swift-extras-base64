// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "Base64KitPerformanceTest",
  products: [

  ],
  dependencies: [
    .package(path: ".."),
    .package(url: "https://github.com/apple/swift-nio.git", from: "2.13.0")
  ],
  targets: [
    .target(
      name: "Base64KitPerformanceTest",
      dependencies: ["Base64Kit", "NIO"]),
  ]
)
