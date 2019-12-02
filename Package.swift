// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "swift-base64",
  products: [
    .library(
      name: "Base64",
      targets: ["Base64"]),
  ],
  dependencies: [],
  targets: [
    .target(
      name: "Base64",
      dependencies: []),
    .testTarget(
      name: "Base64Tests",
      dependencies: ["Base64"]),
  ]
)
