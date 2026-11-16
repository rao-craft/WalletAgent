import XCTest
@testable import WalletAgent

/// The lines a model writes, read: every form the guide promises, and a reason for every line refused.
final class LineTests: XCTestCase {
    // MARK: Mapping

    func testAMappingLineOfBarePaths() throws {
        let mapping = try MappingLine.parse("wallet: Wallet balance=balance earned=totals.earned spent=stats?.spent groups=groups")
        XCTAssertEqual(mapping.role, .wallet)
        XCTAssertEqual(mapping.type, "Wallet")
        XCTAssertEqual(mapping.assignments.map(\.property.member), ["walletBalance", "walletEarned", "walletSpent", "walletGroups"])
        XCTAssertEqual(mapping.assignments.map(\.source), [.path("balance"), .path("totals.earned"), .path("stats?.spent"), .path("groups")])
    }

    func testExpressionsAliasesModulesAndRootsAreRead() throws {
        let mapping = try MappingLine.parse(#"spend: SeerKit.CreditExchange title=value.kind ?? "Inference", createdAt = when, netCost=self.net savings=value.fee * 2"#)
        XCTAssertEqual(mapping.role, .exchange, "`spend` is an exchange")
        XCTAssertEqual(mapping.type, "SeerKit.CreditExchange")
        XCTAssertEqual(mapping.fileStem, "SeerKitCreditExchange")
        XCTAssertEqual(mapping.assignments.map(\.property.key), ["title", "date", "cost", "savings"], "aliases name their property")
        XCTAssertEqual(mapping.assignments.map(\.source), [.expression(#"value.kind ?? "Inference""#), .path("when"), .path("net"),
                                                           .expression("value.fee * 2")])
    }

    func testMappingLinesThatAreRefusedSayWhy() {
        let refused: [(String, String)] = [
            ("wallet Wallet balance=balance", "has no colon"),
            ("purse2: Wallet balance=balance", "is not a role"),
            ("wallet: wallet balance=balance", "is not a type name"),
            ("group: Box<Model> name=name", "is not a type name"),
            ("group: Model colour=red", "a group maps name, documents, earnings"),
            ("wallet: Wallet balance=a balance=b", "`balance` is mapped twice"),
            ("exchange: Spend cost=", "has `=` and no value"),
            ("transaction: Cashout", "it maps nothing"),
            ("transaction: Cashout stray amount=amount", "`stray` is not `word=value`"),
            ("", "it is empty"),
        ]
        for (line, reason) in refused {
            XCTAssertThrowsError(try MappingLine.parse(line), line) { error in
                XCTAssertTrue("\(error)".contains(reason), "\(line) → \(error)")
            }
        }
    }

    func testEveryRoleKnowsItsWordsOnce() {
        for role in WalletRole.allCases {
            var words: Set<String> = []
            for property in role.properties {
                for word in [property.key] + property.aliases {
                    XCTAssertTrue(words.insert(word.lowercased()).inserted, "\(role).\(word) names two properties")
                }
                XCTAssertTrue(property.member.hasPrefix("wallet"), "\(property.member) is namespaced")
                XCTAssertTrue(property.doc.hasSuffix("."), "\(property.member)'s doc is a sentence")
            }
            XCTAssertNotNil(role.property(named: role.properties[0].key.uppercased()), "words are read in any case")
        }
        var roleWords: Set<String> = []
        for role in WalletRole.allCases {
            for word in [role.rawValue] + role.aliases { XCTAssertTrue(roleWords.insert(word).inserted, "\(word) names two roles") }
        }
    }

    // MARK: Look

    func testLookLinesMapARoleToTheAppsName() throws {
        let accepted = ["title = Font.brandTitle", "accent=Color.accent", "note2 = .footnote", "gutter = CGFloat.layer7", "gutter = 24",
                        "SECONDARYBACKGROUND = Color(white: 0.95)"]
        for line in accepted {
            guard case .success = LookLine.parse(line, roles: WalletTables.look) else { return XCTFail(line) }
        }
        guard case .success(let parsed) = LookLine.parse("heading = Font.brandBody2", roles: WalletTables.look) else { return XCTFail() }
        XCTAssertEqual(parsed.role.key, "heading")
        XCTAssertEqual(parsed.expression, "Font.brandBody2")
    }

    func testLookLinesThatAreRefusedSayWhy() {
        let refused: [(String, String)] = [
            ("title Font.brandTitle", "a look line is `role = the app's name`"),
            ("hero = Font.brandTitle", "`hero` is not a look role; the roles are title, heading"),
            ("title = Color.accent", "`title` is a Font"),
            ("accent = \"bronze\"", "`accent` is a Color"),
            ("gutter = wide", "`gutter` is a CGFloat"),
        ]
        for (line, reason) in refused {
            guard case .failure(let error) = LookLine.parse(line, roles: WalletTables.look) else { XCTFail(line); continue }
            XCTAssertTrue("\(error)".contains(reason), "\(line) → \(error)")
        }
    }

    // MARK: Strings

    func testStringsLinesSetAWordQuotedOrNot() throws {
        let cases: [(String, String, String)] = [
            ("title = Wallet", "title", "Wallet"),
            ("groups.title = \"Model Groups\"", "groups.title", "Model Groups"),
            ("loading = Loading wallet…", "loading", "Loading wallet…"),
            ("available = {amount} available", "available", "{amount} available"),
            ("amount = %.4f cr", "amount", "%.4f cr"),
            ("amount = $%.2f", "amount", "$%.2f"),
            ("withdraw.privacy = \"Encrypted,\\nnever stored.\"", "withdraw.privacy", "Encrypted,\nnever stored."),
            ("group.documents.one = {count} document", "group.documents.one", "{count} document"),
        ]
        for (line, key, text) in cases {
            guard case .success(let parsed) = StringsLine.parse(line, keys: WalletTables.strings) else { XCTFail(line); continue }
            XCTAssertEqual(parsed.key.key, key, line)
            XCTAssertEqual(parsed.text, text, line)
        }
    }

    func testStringsLinesThatAreRefusedSayWhy() {
        let refused: [(String, String)] = [
            ("title: Wallet", "a strings line is `key = words`"),
            ("colour = red", "`colour` is not a string key; the keys are title, amount"),
            ("title = \"\"", "`title` is empty"),
            ("amount = cr", "`amount` is how every amount reads"),
            ("amount = %.4f %d", "`amount` is how every amount reads"),
            ("available = available now", "`available` says `{amount}`"),
            ("earned = {amount} earned", "`earned` says no `{…}`"),
        ]
        for (line, reason) in refused {
            guard case .failure(let error) = StringsLine.parse(line, keys: WalletTables.strings) else { XCTFail(line); continue }
            XCTAssertTrue("\(error)".contains(reason), "\(line) → \(error)")
        }
    }

    // MARK: Tuning

    func testTuningLinesAreMadeRegular() throws {
        let cases: [(String, String)] = [
            ("eyebrowTracking = 2.5", "2.5"), ("groupCard = 150x120", "150x120"), ("groupCard = 150 × 120", "150x120"),
            ("exchangesShown = 6", "6"), ("availableSymbol = arrow.up.circle.fill", "arrow.up.circle.fill"),
            ("design = Serif", "serif"), ("material = ultraThin", "ultraThin"), ("material = regularMaterial", "regular"),
            ("amountAnimation = .easeOut(duration: 0.4)", ".easeOut(duration: 0.4)"),
            ("amountAnimation = spring(response:0.38,dampingFraction:0.88)", ".spring(response: 0.38, dampingFraction: 0.88)"),
            ("amountAnimation = .smooth", ".smooth"),
        ]
        for (line, value) in cases {
            guard case .success(let parsed) = TuningLine.parse(line, keys: WalletTables.tuning) else { XCTFail(line); continue }
            XCTAssertEqual(parsed.value, value, line)
        }
    }

    func testTuningLinesThatAreRefusedSayWhy() {
        let refused: [(String, String)] = [
            ("groupCard 150x120", "a tuning line is `key = value`"),
            ("cardSize = 150x120", "`cardSize` is not a tuning key; the keys are eyebrowTracking"),
            ("groupCard = big", "`groupCard` takes a size, width x height"),
            ("eyebrowTracking = wide", "`eyebrowTracking` takes a number"),
            ("exchangesShown = 2.5", "`exchangesShown` takes a whole number"),
            ("availableSymbol = Arrow Up", "`availableSymbol` takes an SF Symbol's name"),
            ("design = comic", "`design` takes a font design"),
            ("material = glass", "`material` takes a material"),
            ("amountAnimation = .wobble(3)", "`amountAnimation` takes an animation"),
        ]
        for (line, reason) in refused {
            guard case .failure(let error) = TuningLine.parse(line, keys: WalletTables.tuning) else { XCTFail(line); continue }
            XCTAssertTrue("\(error)".contains(reason), "\(line) → \(error)")
        }
    }

    // MARK: Launch

    func testLaunchLinesMapADestinationToAState() throws {
        guard case .success(let parsed) = LaunchLine.parse("wallet.exchanges = exchanges", states: WalletTables.launch) else { return XCTFail() }
        XCTAssertEqual(parsed.destination, "wallet.exchanges")
        XCTAssertEqual(parsed.state.name, "exchanges")
        XCTAssertEqual(parsed.ids, [])
    }

    func testLaunchLinesThatAreRefusedSayWhy() {
        let refused: [(String, String)] = [
            ("wallet.exchanges exchanges", "a launch line is `destination = state`"),
            ("wallet exchanges = exchanges", "is not a destination name"),
            ("wallet = history", "`history` is not a state the kit opens in; the states are wallet, exchanges"),
            ("wallet = exchanges(one)", "`exchanges` takes nothing in parentheses"),
        ]
        for (line, reason) in refused {
            guard case .failure(let error) = LaunchLine.parse(line, states: WalletTables.launch) else { XCTFail(line); continue }
            XCTAssertTrue("\(error)".contains(reason), "\(line) → \(error)")
        }
    }

    func testEveryKeyIsKnownOnceAndDocumented() {
        for (name, keys) in [("look", WalletTables.look.map(\.key)), ("strings", WalletTables.strings.map(\.key)),
                             ("tuning", WalletTables.tuning.map(\.key)), ("launch", WalletTables.launch.map(\.name))] {
            XCTAssertEqual(Set(keys).count, keys.count, "\(name) names a key twice")
        }
        for key in WalletTables.strings {
            XCTAssertTrue(key.doc.hasSuffix("."), key.key)
            if key.isSingular { XCTAssertNotNil(WalletTables.strings.first { $0.key + ".one" == key.key }, "\(key.key) is the form of a key") }
        }
        for key in WalletTables.tuning {
            XCTAssertNotNil(TuningLine.regular(key.value, as: key.kind), "\(key.key)'s default reads as \(key.kind)")
        }
        for role in WalletTables.look where !role.fallback.contains("\n") {
            XCTAssertTrue(LookLine.shaped(role.fallback, as: role.kind), "\(role.key)'s fallback reads as a \(role.kind.rawValue)")
        }
    }
}
