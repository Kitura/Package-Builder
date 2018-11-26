// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "library",
    products: [
        .library(name: "library", targets: ["library"]),
    ],
    targets: [
        .target(name: "library", dependencies: []),
    ]
)
