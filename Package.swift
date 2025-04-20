// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Quranely",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "Quranely",
            targets: ["Quranely"]
        ),
    ],
    targets: [
        .target(
            name: "Quranely",
            dependencies: [],
            resources: [
                .process("Resources")
            ]
        )
    ]
)
