// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TwoFa",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/norio-nomura/Base32", from: "0.5.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "TwoFa",
            dependencies: ["TwoFaCore"]),
        .target(
            name: "TwoFaCore",
            dependencies: ["Base32", "Commander", "Rainbow"]),
        .testTarget(
            name: "TwoFaTests",
            dependencies: ["TwoFa"]),
        .testTarget(
            name: "TwoFaCoreTests",
            dependencies: ["TwoFaCore"]),
    ]
)
