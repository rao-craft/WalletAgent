// swift-tools-version:6.0
// WalletAgent: a credits wallet (the balance and earnings, three totals, the groups that earned, the exchanges that
// spent, the cashouts, and the sheets behind them) as plain SwiftUI any app can use, written into an app from its
// own types, as a Granite agent package. An app that links it finds the `wallet` agent through Granite's roster,
// with nothing listed by hand.

import PackageDescription

let package = Package(
    name: "WalletAgent",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "WalletAgent", targets: ["WalletAgent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/riteshpakala/Granite.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "WalletAgent",
            dependencies: [.product(name: "GraniteAgents", package: "Granite")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(
            name: "WalletAgentTests",
            dependencies: ["WalletAgent", .product(name: "GraniteAgents", package: "Granite")],
            swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
