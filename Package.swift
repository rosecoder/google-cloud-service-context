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
        .package(url: "https://github.com/apple/swift-log.git", from: "1.4.2"),
        .package(url: "https://github.com/swift-server/swift-service-lifecycle.git", from: "2.0.0"),
        .package(url: "https://github.com/swift-server/async-http-client.git", from: "1.24.0"),
        .package(url: "https://github.com/rosecoder/retryable-task.git", from: "1.1.2"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.44.0"), // only used for tests
    ],
    targets: [
        .target(
            name: "GoogleCloudServiceContext",
            dependencies: [
                .product(name: "ServiceContextModule", package: "swift-service-context"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "ServiceLifecycle", package: "swift-service-lifecycle"),
                .product(name: "RetryableTask", package: "retryable-task"),
                .product(name: "AsyncHTTPClient", package: "async-http-client"),
            ]
        ),
        .testTarget(name: "GoogleCloudServiceContextTests", dependencies: [
            "GoogleCloudServiceContext",
            .product(name: "NIO", package: "swift-nio"),
            .product(name: "NIOHTTP1", package: "swift-nio"),
        ]),
    ]
)
