// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "Brink",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Brink", targets: ["Brink"]),
        .library(name: "BrinkCore", targets: ["BrinkCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/MrKai77/DynamicNotchKit", from: "1.1.0"),
    ],
    targets: [
        .target(name: "BrinkCore"),
        .executableTarget(
            name: "Brink",
            dependencies: [
                "BrinkCore",
                .product(name: "DynamicNotchKit", package: "DynamicNotchKit"),
            ]
        ),
        .testTarget(name: "BrinkCoreTests", dependencies: ["BrinkCore"]),
    ]
)
