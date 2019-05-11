// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let twoFaTarget : Target 

#if os(OSX)
twoFaTarget = Target.target(
            name: "TwoFa",
            dependencies: ["TwoFaCore", "KeychainAccess"])
#endif

var package = Package(
    name: "TwoFa",
    dependencies: [
        .package(url: "https://github.com/kylef/Commander", from: "0.8.0"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0"),
        .package(url: "https://github.com/norio-nomura/Base32", from: "0.5.4"),
        //.package(url: "https://github.com/lachlanbell/SwiftOTP", from: "1.0.0"),
        .package(url: "https://github.com/kirsis/OneTimePassword", .branch("swiftpmtest")),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        twoFaTarget,
        .target(
            name: "TwoFaCore",
            dependencies: ["Base32", "Commander", "Rainbow", "OneTimePassword"]),
        .testTarget(
            name: "TwoFaTests",
            dependencies: ["TwoFa"]),
        .testTarget(
            name: "TwoFaCoreTests",
            dependencies: ["TwoFaCore"]),
    ]
)
#if os(OSX)
        package.dependencies.append(.package(url: "https://github.com/kishikawakatsumi/KeychainAccess", from: "3.0.0"))

#endif
