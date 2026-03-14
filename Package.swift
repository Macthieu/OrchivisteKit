// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "OrchivisteKit",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "OrchivisteKitContracts", targets: ["OrchivisteKitContracts"]),
        .library(name: "OrchivisteKitConfig", targets: ["OrchivisteKitConfig"]),
        .library(name: "OrchivisteKitObservability", targets: ["OrchivisteKitObservability"]),
        .library(name: "OrchivisteKitInterop", targets: ["OrchivisteKitInterop"])
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-testing.git", from: "0.7.0")
    ],
    targets: [
        .target(name: "OrchivisteKitContracts"),
        .target(name: "OrchivisteKitConfig", dependencies: ["OrchivisteKitContracts"]),
        .target(name: "OrchivisteKitObservability", dependencies: ["OrchivisteKitContracts"]),
        .target(
            name: "OrchivisteKitInterop",
            dependencies: [
                "OrchivisteKitContracts",
                "OrchivisteKitConfig",
                "OrchivisteKitObservability"
            ]
        ),
        .testTarget(
            name: "OrchivisteKitContractsTests",
            dependencies: [
                "OrchivisteKitContracts",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .testTarget(
            name: "OrchivisteKitConfigTests",
            dependencies: [
                "OrchivisteKitConfig",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .testTarget(
            name: "OrchivisteKitObservabilityTests",
            dependencies: [
                "OrchivisteKitObservability",
                .product(name: "Testing", package: "swift-testing")
            ]
        ),
        .testTarget(
            name: "OrchivisteKitInteropTests",
            dependencies: [
                "OrchivisteKitInterop",
                "OrchivisteKitContracts",
                .product(name: "Testing", package: "swift-testing")
            ]
        )
    ]
)
