// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BearJanitor",
    dependencies: [
        .package(url: "https://github.com/groue/GRDB.swift.git", .branch("v4.14.0")),
        .package(url: "https://github.com/tonyarnold/Differ.git", from: "1.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "BearJanitor",
            dependencies: ["GRDB", "Differ"]),
        .testTarget(
            name: "BearJanitorTests",
            dependencies: ["BearJanitor"]),
    ]
)
