// swift-tools-version:5.2

import PackageDescription

let package = Package(
    name: "firebase-cloud-messaging",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "FCM",
            targets: ["FCM"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
        .package(url: "https://github.com/vapor-community/google-cloud-kit.git", .exact("1.0.0-rc.9")),
    ],
    targets: [
        .target(
            name: "GoogleCloud",
            dependencies: [
                .product(name: "Vapor", package: "vapor"),
                .product(name: "GoogleCloudKit", package: "google-cloud-kit"),
            ]),
        .target(name: "FCM", dependencies: [
            .product(name: "Vapor", package: "vapor"),
            .target(name: "GoogleCloud")
        ]),
    ]
)
