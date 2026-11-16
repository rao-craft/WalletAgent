import Foundation
import XCTest
@testable import WalletAgent

/// What a call writes: which files, under which names, what the Seer call's output says, and the same bytes again.
final class EmitTests: XCTestCase {
    private func write(_ input: WalletAgent.Input, into folder: URL) throws -> WalletResult {
        var call = input
        call.directory = folder.path
        return try WalletAgent.write(call, note: { _ in }, yield: { _ in })
    }

    private func names(_ result: WalletResult) -> Set<String> {
        Set(result.paths.map { URL(fileURLWithPath: $0).lastPathComponent })
    }

    func testTheSeerCallWritesTheKitAndOneConformanceALine() throws {
        let folder = try Fixture.folder()
        let result = try write(try Fixture.example("seer"), into: folder)
        XCTAssertEqual(names(result), [
            "WalletProtocols.swift", "WalletValue.swift", "WalletLook.swift", "WalletStrings.swift", "WalletLaunch.swift",
            "WalletSupport.swift", "WalletEyebrow.swift", "WalletCloseButton.swift", "WalletHeroView.swift", "WalletTotalsView.swift",
            "WalletSection.swift", "WalletGroupCard.swift", "WalletExchangeCard.swift", "WalletExchangeRow.swift",
            "WalletTransactionRow.swift", "WalletExchangesSheet.swift", "WalletExchangeSheet.swift", "WalletView.swift",
            "WalletPreviews.swift", "WalletWithdrawButton.swift", "WalletWithdrawSheet.swift", "Wallet+Wallet.swift",
            "ModelEarning+Group.swift", "CreditExchange+Exchange.swift", "Cashout+Transaction.swift",
        ], "withdraw: soon writes the faded button, and the sheet for the line that opens it")
        let conformance = try Fixture.text(result.paths, "Wallet+Wallet.swift")
        XCTAssertEqual(conformance, """
        import Foundation
        import SeerKit

        /// A `Wallet` as the wallet views show a wallet.
        extension Wallet: WalletRepresentable {
            typealias GroupValue = ModelEarning
            typealias ExchangeValue = CreditExchange
            typealias TransactionValue = Cashout

            var walletBalance: Double { WalletValue.amount(self.balance) }
            var walletEarned: Double { WalletValue.amount(self.earned) }
            var walletSpent: Double { WalletValue.amount(self.spent) }
            var walletCashedOut: Double { WalletValue.amount(self.cashedOut) }
            var walletGroups: [GroupValue] { WalletValue.list(self.groups) }
            var walletExchanges: [ExchangeValue] { WalletValue.list(self.exchanges) }
            var walletTransactions: [TransactionValue] { WalletValue.list(self.cashouts) }
        }

        """)
        XCTAssertTrue(try Fixture.text(result.paths, "CreditExchange+Exchange.swift")
            .contains("var walletExchangeSavings: Double { WalletValue.amount(self.savings) }"))
    }

    /// Every `code` item of the scorecard's `wallet` area but the mock wallet's matches the Seer call's output.
    func testTheSeerCallsOutputMatchesTheScorecardsCodeFacts() throws {
        let code = try Fixture.all(try write(try Fixture.example("seer"), into: try Fixture.folder()).paths)
        for item in Fixture.scorecard {
            for pattern in item.all {
                XCTAssertNotNil(code.range(of: pattern, options: .regularExpression), "\(item.id): \(pattern)")
            }
        }
        XCTAssertNil(code.range(of: #"\b23\.75\b|\b0\.235\b|\b0\.145\b|\b0\.175\b"#, options: .regularExpression),
                     "B-wallet-11 is the mock wallet's: the kit's samples never stand in for it")
    }

    /// The withdrawal as the original draws it: the button faded with "Coming soon" under it, and the Connect Bank
    /// sheet a `wallet.withdraw` launch opens, which sends nothing.
    func testTheSeerCallsWithdrawalIsTheOriginals() throws {
        let result = try write(try Fixture.example("seer"), into: try Fixture.folder())
        let root = try Fixture.text(result.paths, "WalletView.swift")
        XCTAssertTrue(root.contains("WalletWithdrawButton()"), "the faded button")
        XCTAssertTrue(root.contains("WalletWithdrawSheet(available: wallet.walletAvailable)"), "the sheet, with no closure to send to")
        XCTAssertTrue(root.contains("case .withdraw:\n                withdrawing = true"), "opened for the launch")
        let button = try Fixture.text(result.paths, "WalletWithdrawButton.swift")
        XCTAssertTrue(button.contains(".modifier(WalletOutlined(enabled: isEnabled))"))
        XCTAssertTrue(button.contains(".font(.system(size: 11, weight: .regular, design: .serif))"))
        XCTAssertTrue(button.contains("false\n    }"), "never enabled")
        let sheet = try Fixture.text(result.paths, "WalletWithdrawSheet.swift")
        XCTAssertTrue(sheet.contains("action(WalletStrings.withdrawConfirm, enabled: false) {}"), "nothing is sent")
        XCTAssertNil(sheet.range(of: "let withdraw:|withdraw: \\{|func send", options: .regularExpression), "no closure, nothing to send")
        XCTAssertTrue(sheet.contains(".animation(.easeInOut(duration: 0.26), value: step)"))
        XCTAssertTrue(sheet.contains(".font(WalletLook.body)"))
        XCTAssertTrue(sheet.contains("Image(systemName: \"building.columns\")"))
        XCTAssertEqual(result.roots, ["WalletView(wallet: Wallet?, load: (() async throws -> Void)? = nil, close: (() -> Void)? = nil)"])
    }

    /// Every word the spec quotes for Wallet, All Exchanges and an exchange's sheet is in the Seer call's output.
    func testEveryQuotedWordOfTheSpecIsWritten() throws {
        let code = try Fixture.all(try write(try Fixture.example("seer"), into: try Fixture.folder()).paths)
        for word in Fixture.quoted {
            XCTAssertNotNil(code.range(of: word), word)
        }
        let strings = try Fixture.text(try write(try Fixture.example("seer"), into: try Fixture.folder()).paths, "WalletStrings.swift")
        for line in [
            #"static var amount: String { "%.4f cr" }"#,
            #"static var balanceEyebrow: String { "CREDIT BALANCE" }"#,
            #"static func available(_ amount: String) -> String { "\(amount) available" }"#,
            #"static func groupDocuments(_ count: Int) -> String { count == 1 ? "\(count) document" : "\(count) documents" }"#,
            #"static var exchangeTitle: String { "Inference" }"#,
            #"static var loading: String { "Loading wallet…" }"#,
            #"static func exchangeSaved(_ amount: String) -> String { "-\(amount)" }"#,
            #"static var balanceNumber: String { "%.4f" }"#,
            #"static var balanceUnit: String { "cr" }"#,
            #"static var withdrawSoon: String { "Coming soon" }"#,
            #"static var withdrawBankTitle: String { "Connect Bank" }"#,
            #"static var withdrawPrivacy: String { "Your account details are encrypted\nand never stored on our servers." }"#,
            #"static func withdrawAvailable(_ amount: String) -> String { "Available: \(amount)" }"#,
        ] {
            XCTAssertTrue(strings.contains(line), line)
        }
    }

    func testTheSeerCallsLookAndLaunchAreTheAppsNames() throws {
        let result = try write(try Fixture.example("seer"), into: try Fixture.folder())
        let look = try Fixture.text(result.paths, "WalletLook.swift")
        for line in ["static var title: Font { Font.brandTitle }", "static var body: Font { Font.brandBody }",
                     "static var note2: Font { Font.brandNote2 }", "static var accent: Color { Color.accent }",
                     "static var gutter: CGFloat { CGFloat.layer7 }", "static var positive: Color { .green }"] {
            XCTAssertTrue(look.contains(line), line)
        }
        let launch = try Fixture.text(result.paths, "WalletLaunch.swift")
        XCTAssertTrue(launch.contains(#"switch UserDefaults.standard.string(forKey: "destination") {"#))
        XCTAssertTrue(launch.contains(#"case "wallet.exchanges": return .exchanges"#))
        XCTAssertTrue(launch.contains(#"case "wallet.withdraw": return .withdraw"#))
        let hero = try Fixture.text(result.paths, "WalletHeroView.swift")
        XCTAssertTrue(hero.contains(".font(.system(size: 34, weight: .light, design: .serif))"))
        XCTAssertTrue(hero.contains(".animation(.easeOut(duration: 0.4), value: balance)"))
        XCTAssertNil(hero.range(of: "lineLimit|minimumScaleFactor|fixedSize", options: .regularExpression), "the balance wraps, as the original's does")
        XCTAssertTrue(try Fixture.text(result.paths, "WalletView.swift").contains(".presentationBackground(.regularMaterial)"))
    }

    func testTheSameCallWritesTheSameBytes() throws {
        let folder = try Fixture.folder()
        let first = try write(try Fixture.example("seer"), into: folder)
        let texts = try first.paths.map { try String(contentsOfFile: $0, encoding: .utf8) }
        let second = try write(try Fixture.example("seer"), into: folder)
        XCTAssertEqual(second.paths, first.paths)
        XCTAssertEqual(try second.paths.map { try String(contentsOfFile: $0, encoding: .utf8) }, texts)
        XCTAssertEqual(Set(second.made.map(\.state)), [.unchanged], "written again to the same text")
        // And into another folder: nothing depends on where or when.
        let elsewhere = try write(try Fixture.example("seer"), into: try Fixture.folder())
        XCTAssertEqual(try elsewhere.paths.map { try String(contentsOfFile: $0, encoding: .utf8) }, texts)
    }

    func testWithdrawOnSoonAndOff() throws {
        var call = WalletAgent.Input()
        call.withdraw = .soon
        let soon = try write(call, into: try Fixture.folder())
        XCTAssertTrue(names(soon).contains("WalletWithdrawButton.swift"))
        XCTAssertFalse(names(soon).contains("WalletWithdrawSheet.swift"), "no line opens the sheet, and no button can")
        let soonStrings = try Fixture.text(soon.paths, "WalletStrings.swift")
        XCTAssertTrue(soonStrings.contains(#"static var withdrawSoon: String { "Coming soon" }"#))
        XCTAssertFalse(soonStrings.contains("withdrawBank"), "no word of the sheet without it")
        XCTAssertTrue(try Fixture.text(soon.paths, "WalletView.swift").contains("WalletWithdrawButton()"))
        XCTAssertFalse(try Fixture.text(soon.paths, "WalletLaunch.swift").contains("case withdraw"))

        call.launch = ["wallet.withdraw = withdraw"]
        let launched = try write(call, into: try Fixture.folder())
        XCTAssertTrue(names(launched).isSuperset(of: ["WalletWithdrawButton.swift", "WalletWithdrawSheet.swift"]), "soon with the line writes the sheet")
        XCTAssertEqual(launched.roots, ["WalletView(wallet: WalletItem?, load: (() async throws -> Void)? = nil, close: (() -> Void)? = nil)"])
        XCTAssertTrue(try Fixture.text(launched.paths, "WalletLaunch.swift").contains(#"case "wallet.withdraw": return .withdraw"#))
        XCTAssertFalse(try Fixture.text(launched.paths, "WalletStrings.swift").contains("withdrawFailed"), "nothing is sent, so nothing fails")
        XCTAssertEqual(launched.notes.filter { $0.contains("withdraw") }, [])

        call.withdraw = .on
        let on = try write(call, into: try Fixture.folder())
        XCTAssertTrue(names(on).isSuperset(of: ["WalletWithdrawButton.swift", "WalletWithdrawSheet.swift"]))
        XCTAssertEqual(on.roots, ["WalletView(wallet: WalletItem?, load: (() async throws -> Void)? = nil, withdraw: ((WalletWithdrawal) async throws -> Void)? = nil, close: (() -> Void)? = nil)"])
        XCTAssertFalse(try Fixture.text(on.paths, "WalletStrings.swift").contains("withdrawSoon"))
        XCTAssertTrue(try Fixture.text(on.paths, "WalletWithdrawSheet.swift").contains("try await withdraw(WalletWithdrawal("))
        XCTAssertTrue(try Fixture.text(on.paths, "WalletLaunch.swift").contains(#"case "wallet.withdraw": return .withdraw"#))

        call.withdraw = .off
        XCTAssertThrowsError(try write(call, into: try Fixture.folder())) { error in
            XCTAssertTrue("\(error)".contains("`withdraw` opens the withdrawal sheet, which `withdraw: off` leaves out: say `withdraw: on` or `soon`"), "\(error)")
        }
        call.launch = nil
        call.strings = ["withdraw.bank.title = Link a Bank", "withdraw.soon = Later"]
        let notes = try write(call, into: try Fixture.folder()).notes
        XCTAssertTrue(notes.contains("`withdraw.bank.title` is said only in the withdrawal sheet, written with `withdraw: on`, or `soon` with a `withdraw` launch line, so it is not written."), "\(notes)")
        XCTAssertTrue(notes.contains("`withdraw.soon` is said only with `withdraw: soon`, so it is not written."), "\(notes)")
    }

    /// A later call into the same folder takes away what it no longer writes: the withdrawal, a conformance.
    func testALaterCallTakesAwayWhatItNoLongerWrites() throws {
        let folder = try Fixture.folder()
        var call = WalletAgent.Input(mappings: ["wallet: Purse balance=coins", "group: Pocket name=label earnings=coins"])
        let first = try write(call, into: folder)
        XCTAssertTrue(names(first).contains("WalletWithdrawSheet.swift"))
        call.mappings = ["wallet: Purse balance=coins"]
        call.withdraw = .off
        let second = try write(call, into: folder)
        let removed = second.made.filter { $0.state == .removed }.map { URL(fileURLWithPath: $0.path ?? "").lastPathComponent }
        XCTAssertEqual(Set(removed), ["WalletWithdrawButton.swift", "WalletWithdrawSheet.swift", "Pocket+Group.swift"])
        for path in second.made.filter({ $0.state == .removed }).compactMap(\.path) {
            XCTAssertFalse(FileManager.default.fileExists(atPath: path), path)
        }
    }

    func testAPrefixRenamesEveryNameTheKitDeclaresAndNoneOfTheApps() throws {
        let folder = try Fixture.folder()
        let result = try write(try Fixture.example("reading-points"), into: folder)
        XCTAssertTrue(result.paths.allSatisfy { $0.hasPrefix(folder.appendingPathComponent("Shared/Views/Points").path + "/") })
        XCTAssertTrue(names(result).isSuperset(of: ["PointsView.swift", "PointsLook.swift", "PointsWithdrawSheet.swift", "Account+Wallet.swift"]))
        let code = try Fixture.all(result.paths)
        for name in KitCatalog.names {
            XCTAssertNil(code.range(of: #"(?<![A-Za-z0-9_])"# + name + #"(?![A-Za-z0-9_])"#, options: .regularExpression), "\(name) is renamed")
        }
        XCTAssertTrue(code.contains("extension Account: PointsRepresentable {"))
        XCTAssertTrue(code.contains("typealias GroupValue = Shelf"))
        XCTAssertTrue(code.contains("let value = self\n        return WalletValue".replacingOccurrences(of: "WalletValue", with: "PointsValue")))
        XCTAssertEqual(result.roots, ["PointsView(wallet: Account?, load: (() async throws -> Void)? = nil, withdraw: ((PointsWithdrawal) async throws -> Void)? = nil, close: (() -> Void)? = nil)"])
        XCTAssertTrue(code.contains(#"static var amount: String { "%.0f pts" }"#))
    }

    func testTheAppsTypesAreReadToCheckEachPath() throws {
        let folder = try Fixture.folder()
        try FileManager.default.createDirectory(at: folder.appendingPathComponent("Shared"), withIntermediateDirectories: true)
        try Fixture.readingModels.write(to: folder.appendingPathComponent("Shared/Models.swift"), atomically: true, encoding: .utf8)
        // The second example reads well against the types it was written for.
        XCTAssertNoThrow(try write(try Fixture.example("reading-points"), into: folder))
        let wrong = WalletAgent.Input(mappings: [
            "wallet: Account balance=pointz groups=shelves exchanges=shelves",
            "group: Shelf name=books",
            "exchange: Purchase cost=price date=boughtAt",
        ])
        XCTAssertThrowsError(try write(wrong, into: folder)) { error in
            let text = "\(error)"
            for reason in ["wallet balance=pointz: `Account` has no `pointz`: its fields are points, lifetimePoints",
                           "group name=books: `books` is `[String]`, and `name` shows text",
                           "wallet exchanges=shelves: `shelves` holds Shelf, and the exchange line maps Purchase"] {
                XCTAssertTrue(text.contains(reason), "\(reason) in \(text)")
            }
        }
    }

    func testAListNeedsTheLineOfItsRole() throws {
        let call = WalletAgent.Input(mappings: ["wallet: Purse balance=coins groups=pockets"])
        XCTAssertThrowsError(try write(call, into: try Fixture.folder())) { error in
            XCTAssertTrue("\(error)".contains("wallet groups=… shows groups, and no `group:` line says how"), "\(error)")
        }
    }

    func testNotesSayWhatTheAppStillHasToDo() throws {
        let result = try write(WalletAgent.Input(mappings: ["group: Pocket name=label", "exchange: Spend cost=nil"]), into: try Fixture.folder())
        XCTAssertTrue(result.notes.contains { $0.hasPrefix("Left out cost=nil") })
        XCTAssertTrue(result.notes.contains { $0.hasPrefix("No `wallet:` line") })
        XCTAssertTrue(result.notes.contains { $0.hasPrefix("No `look` lines") })
        XCTAssertTrue(result.notes.contains { $0.hasPrefix("The Withdraw button is drawn when the page passes `withdraw:`") })
    }
}
