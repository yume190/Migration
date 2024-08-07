// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Migration",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .executable(name: "migration", targets: ["Migration"]),
        .library(name: "MigrationKit", targets: ["MigrationKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        
        .package(
            url: "https://github.com/apple/swift-syntax.git",
            from: "509.1.0"
        ),
        
        .package(
            url: "https://github.com/apple/indexstore-db",
            revision: "swift-5.9.2-RELEASE"
        ),

        .package(
            url: "https://github.com/yume190/TypeFill",
            from: "0.5.0"
        ),

        .package(url: "https://github.com/jpsim/SourceKitten", from: "0.35.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.2.2"),
        .package(url: "https://github.com/onevcat/Rainbow", from: "4.0.1"),
        .package(url: "https://github.com/zonble/HumanString.git", from: "0.1.1"),
        .package(url: "https://github.com/kylef/PathKit", from: "1.0.1"),
        .package(url: "https://github.com/jpsim/Yams", from: "5.0.5"),
        .package(url: "https://github.com/Zollerboy1/SwiftCommand", from: "1.4.0"),
    ],
    targets: [
        .executableTarget(
            name: "Migration",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "SourceKittenFramework", package: "SourceKitten"),
                .product(name: "SKClient", package: "TypeFill"),
                "MigrationKit",
                "PathKit",
                "Yams",
            ]
        ),

        // MARK: Frameworks

        .target(
            name: "MigrationKit",
            dependencies: [
                "Rainbow",
                "PathKit",
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                
                
                .product(name: "IndexStoreDB", package: "indexstore-db"),
                .product(name: "SKClient", package: "TypeFill"),
            ]
        ),

        // MARK: Tests

        .testTarget(
            name: "MigrationTests",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SKClient", package: "TypeFill"),
                .product(name: "SwiftCommand", package: "SwiftCommand"),
                
                "MigrationKit",
                "HumanString",
            ]
        ),
    ]
)
