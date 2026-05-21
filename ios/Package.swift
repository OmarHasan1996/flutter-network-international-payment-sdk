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
        // NISdk has no Package.swift of its own, so its sources are vendored
        // locally under ios/Sources/NISdk/ via setup_spm.sh.
        // If Network International ever publish an official SPM package, replace
        // the NISdk target below with:
        //   .package(url: "https://github.com/network-international/payment-sdk-ios.git", from: "6.0.0")
    ],
    targets: [
        // ── Your Flutter plugin ──────────────────────────────────────────────
        .target(
            name: "network_international_payment_sdk",
            dependencies: [
                "NISdk"
            ],
            path: "Classes",              // ← your existing Classes/ folder
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
