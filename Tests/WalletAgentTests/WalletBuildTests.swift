import Foundation
import XCTest
@testable import WalletAgent

/// The kit compiled and run as apps would: the Seer call written into a package beside SeerKit, its design names
/// stood in and its page written as the prompt gives it, in Swift 6 and in Swift 5; the reading app's call (its own
/// types, a prefix, the withdrawal); and the least call. Built with `swift build` for the Mac and with `xcodebuild`
/// for the iPhone simulator, then every view drawn offscreen and the conversions read back.
/// Gated (`WALLET_BUILD=1`): the builds take a few minutes.
final class WalletBuildTests: XCTestCase {
    func testTheKitBuildsForMacAndIPhoneInBothLanguageModesAndEveryViewDraws() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["WALLET_BUILD"] == "1", "set WALLET_BUILD=1 to build the output")
        let package = try Fixture.folder()
        func write(_ text: String, _ path: String) throws {
            let url = package.appendingPathComponent(path)
            try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
            try text.write(to: url, atomically: true, encoding: .utf8)
        }

        // The app's own sources first, so the agent reads the types its lines map.
        try write(Fixture.seerKit, "Sources/SeerKit/SeerKit.swift")
        for app in ["Seer", "SeerFive"] {
            try write(WalletApps.seerDesign, "Sources/\(app)/Shared/Design.swift")
            try write(WalletApps.seerSamples, "Sources/\(app)/Shared/Samples.swift")
            try write(WalletApps.seerPage, "Sources/\(app)/Components/WalletPage.swift")
            try write(WalletApps.seerCheck.replacingOccurrences(of: "__APP__", with: app), "Sources/\(app)/\(app)Check.swift")
        }
        try write(Fixture.readingModels, "Sources/Points/Models.swift")
        try write(WalletApps.pointsCheck, "Sources/Points/PointsCheck.swift")
        try write(WalletApps.soonCheck, "Sources/Soon/SoonCheck.swift")

        var written = 0
        let seer = try Fixture.example("seer")
        for app in ["Seer", "SeerFive"] {
            var input = seer
            input.into = "Sources/\(app)/Components/Wallet"
            input.directory = package.path
            let result = try WalletAgent.write(input, note: { _ in }, yield: { _ in })
            XCTAssertEqual(result.notes, [], "the Seer call leaves the app nothing to do but call the root")
            written += result.paths.count
        }
        var points = try Fixture.example("reading-points")
        points.into = "Sources/Points/Shared/Views/Points"
        points.directory = package.path
        written += try WalletAgent.write(points, note: { _ in }, yield: { _ in }).paths.count
        written += try WalletAgent.write(.init(into: "Sources/Soon/Wallet", withdraw: .soon, directory: package.path),
                                         note: { _ in }, yield: { _ in }).paths.count
        XCTAssertGreaterThan(written, 80)

        try write("""
        // swift-tools-version:6.0
        import PackageDescription
        let package = Package(
            name: "WalletApps",
            platforms: [.iOS(.v17), .macOS(.v14)],
            products: [.library(name: "WalletApps", targets: ["Seer", "SeerFive", "Points", "Soon"])],
            targets: [
                .target(name: "SeerKit", swiftSettings: [.swiftLanguageMode(.v6)]),
                .target(name: "Seer", dependencies: ["SeerKit"], swiftSettings: [.swiftLanguageMode(.v6)]),
                .target(name: "SeerFive", dependencies: ["SeerKit"], swiftSettings: [.swiftLanguageMode(.v5)]),
                .target(name: "Points", swiftSettings: [.swiftLanguageMode(.v6)]),
                .target(name: "Soon", swiftSettings: [.swiftLanguageMode(.v6)]),
                .executableTarget(name: "Check", dependencies: ["Seer", "SeerFive", "Points", "Soon"],
                                  swiftSettings: [.swiftLanguageMode(.v6)]),
            ]
        )
        """, "Package.swift")
        try write("""
        import Foundation
        import Seer
        import SeerFive
        import Points
        import Soon

        let results = MainActor.assumeIsolated {
            [SeerCheck.run(), SeerFiveCheck.run(), PointsCheck.run(), SoonCheck.run()]
        }
        let failed = results.flatMap(\\.failed)
        print("drew \\(results.flatMap(\\.drawn).count) views")
        if !failed.isEmpty {
            print("failed: \\(failed)")
            exit(1)
        }
        """, "Sources/Check/main.swift")

        // The Mac: every target, Swift 6 and Swift 5, with no warning in what the kit wrote.
        let mac = try run(["swift", "build", "--package-path", package.path])
        XCTAssertEqual(mac.status, 0, errors(mac.log))
        let kit = ["/Components/Wallet/", "/Shared/Views/Points/", "/Soon/Wallet/"]
        let warnings = mac.log.split(separator: "\n").filter { line in line.contains("warning:") && kit.contains { line.contains($0) } }
        XCTAssertTrue(warnings.isEmpty, warnings.joined(separator: "\n"))

        // Every view drawn from each app's own values, and what the conformances and words read back.
        let drawn = try run(["swift", "run", "--package-path", package.path, "Check"])
        XCTAssertEqual(drawn.status, 0, errors(drawn.log) + String(drawn.log.suffix(1_000)))
        XCTAssertNotNil(drawn.log.range(of: #"drew \d{2,} views"#, options: .regularExpression), drawn.log)

        // The iPhone simulator, built for a generic device: no simulator is booted.
        let phone = try run(["xcodebuild", "-scheme", "WalletApps", "-destination", "generic/platform=iOS Simulator",
                             "-derivedDataPath", package.appendingPathComponent("dd").path,
                             "-skipPackagePluginValidation", "-skipMacroValidation", "build"], in: package)
        XCTAssertTrue(phone.log.contains("** BUILD SUCCEEDED **"), errors(phone.log))
        let phoneWarnings = phone.log.split(separator: "\n").filter { line in line.contains("warning:") && kit.contains { line.contains($0) } }
        XCTAssertTrue(phoneWarnings.isEmpty, Set(phoneWarnings).joined(separator: "\n"))
    }

    /// A build log's errors, each once, without the command lines around them.
    private func errors(_ log: String) -> String {
        var seen: Set<Substring> = []
        return log.split(separator: "\n").filter { $0.contains("error:") && $0.count < 600 && seen.insert($0).inserted }.joined(separator: "\n")
    }

    private func run(_ arguments: [String], in folder: URL? = nil) throws -> (status: Int32, log: String) {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = arguments
        if let folder { process.currentDirectoryURL = folder }
        let out = Pipe()
        process.standardOutput = out
        process.standardError = out
        try process.run()
        let data = out.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()
        return (process.terminationStatus, String(decoding: data, as: UTF8.self))
    }
}
