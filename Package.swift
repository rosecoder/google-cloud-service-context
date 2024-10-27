// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "google-cloud-service-context",
    platforms: [
       .macOS(.v15),
    ],
    products: [
        .library(name: "GoogleCloudServiceContext", targets: ["GoogleCloudServiceContext"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-service-context.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "GoogleCloudServiceContext",
            dependencies: [
                .product(name: "ServiceContextModule", package: "swift-service-context"),
            ]
        ),
        .testTarget(name: "GoogleCloudServiceContextTests", dependencies: ["GoogleCloudServiceContext"]),
    ]
)
