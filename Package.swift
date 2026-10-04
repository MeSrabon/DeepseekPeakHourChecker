// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "DeepSeekPeakHours",
    defaultLocalization: "en",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "DeepSeekPeakHours",
            targets: ["DeepSeekPeakHours"]
        ),
        .library(
            name: "DeepSeekPeakHoursCore",
            targets: ["DeepSeekPeakHoursCore"]
        )
    ],
    targets: [
        .target(
            name: "DeepSeekPeakHoursCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "DeepSeekPeakHours",
            dependencies: [
                "DeepSeekPeakHoursCore"
            ]
        ),
        .executableTarget(
            name: "DeepSeekPeakHoursTests",
            dependencies: [
                "DeepSeekPeakHoursCore"
            ],
            path: "Tests/DeepSeekPeakHoursTests"
        )
    ]
)
