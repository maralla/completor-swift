// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SourceKittenWrapper",
    dependencies: [
        .package(name: "SourceKitten", url: "git@github.com:jpsim/SourceKitten.git", .upToNextMinor(from: .init(0, 31, 0)))
    ],
    targets: [
        .target(name: "SourceKittenWrapper",
                dependencies: [.product(name: "SourceKittenFramework", package: "SourceKitten")]
        )
    ]
)
