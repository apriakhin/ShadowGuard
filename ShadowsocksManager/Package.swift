// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "ShadowsocksManager",
    products: [
        .library(name: "ShadowsocksManager", targets: ["ShadowsocksManager"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.4"),
    ],
    targets: [
        .target(
            name: "ShadowsocksManager",
            dependencies: [
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack"),
                "Tun2socks",
            ],
            path: "Sources"
        ),
        .binaryTarget(
            name: "Tun2socks",
            url: "https://github.com/Jigsaw-Code/outline-go-tun2socks/releases/download/v3.4.0/apple.zip",
            checksum: "6c6880fa7d419a5fddc10588edffa0b23b5a44f0f840cf6865372127285bcc42"
        ),
        .testTarget(
            name: "ShadowsocksManagerTest",
            dependencies: ["ShadowsocksManager"],
            path: "Tests"
        ),
    ]
)
