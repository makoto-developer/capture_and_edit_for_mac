// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CaptureAndEdit",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "CaptureAndEdit",
            targets: ["CaptureAndEditApp"]
        ),
        .library(
            name: "CaptureAndEditLib",
            targets: ["CaptureAndEdit"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CaptureAndEdit",
            dependencies: [],
            path: "Sources/CaptureAndEdit",
            exclude: ["App/CaptureAndEditApp.swift"]
        ),
        .executableTarget(
            name: "CaptureAndEditApp",
            dependencies: ["CaptureAndEdit"],
            path: "Sources/CaptureAndEditApp"
        ),
        .testTarget(
            name: "CaptureAndEditTests",
            dependencies: ["CaptureAndEdit"],
            path: "Tests/CaptureAndEditTests"
        )
    ]
)
