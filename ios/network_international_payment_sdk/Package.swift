// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "network_international_payment_sdk",
    platforms: [
        .iOS(.v14)  // NISdk 6.0.0 requires iOS 14+
    ],
    products: [
        .library(
            name: "network-international-payment-sdk",
            targets: ["network_international_payment_sdk"]
        )
    ],
    dependencies: [
        ///ToDo
        // NISdk has no Package.swift of its own, so its sources are vendored
        // locally under ios/Sources/NISdk/ via setup_spm.sh.
        // If Network International ever publish an official SPM package, replace
        // the NISdk target below with:
        //   .package(url: "https://github.com/network-international/payment-sdk-ios.git", from: "6.0.0")

        // Required by Flutter 3.41+
        .package(name: "FlutterFramework", path: "../FlutterFramework")
    ],
    targets: [
        // ── Your Flutter plugin ──────────────────────────────────────────────
        .target(
            name: "network_international_payment_sdk",
            dependencies: [
                .product(name: "FlutterFramework", package: "FlutterFramework"),
                "NISdk"
            ],
            path: "Sources/network_international_payment_sdk",
            resources: [],
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"])
            ]
        ),

        // ── NISdk vendored source ────────────────────────────────────────────
        // Populated by running:  bash ios/setup_spm.sh
        // This clones NISdk/Source and NISdk/Resources from:
        //   https://github.com/network-international/payment-sdk-ios (tag v6.0.0)
        // into ios/Sources/NISdk/
        .target(
            name: "NISdk",
            dependencies: [],
            path: "Sources/NISdk",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .unsafeFlags(["-suppress-warnings"])
            ]
        )
    ]
)
