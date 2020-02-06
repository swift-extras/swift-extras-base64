// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-base64-kit",
  products: [
    .library(
      name: "Base64Kit",
      targets: ["Base64Kit"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Base64Kit",
      dependencies: []),
    .testTarget(
      name: "Base64KitTests",
      dependencies: ["Base64Kit"]),
  ]
)
