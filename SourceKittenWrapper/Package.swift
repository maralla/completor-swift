import PackageDescription

let package = Package(
    name: "SourceKittenWrapper",
    dependencies: [
        .Package(url: "https://github.com/jpsim/SourceKitten.git", Version(0, 17, 0))
    ]
)
