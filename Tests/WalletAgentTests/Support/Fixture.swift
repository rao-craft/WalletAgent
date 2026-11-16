import Foundation
@testable import WalletAgent

enum Fixture {
    /// A folder of its own for one test, removed with the process's temporary files.
    static func folder() throws -> URL {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("wallet-\(UUID().uuidString.prefix(8))", isDirectory: true)
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    /// The package's own folder, so the tests read the examples the schema ships.
    static let package = URL(fileURLWithPath: #filePath).deletingLastPathComponent().deletingLastPathComponent()
        .deletingLastPathComponent().deletingLastPathComponent()

    /// A call in `Schema/examples/<name>.json`, as a host decodes it.
    static func example(_ name: String) throws -> WalletAgent.Input {
        let data = try Data(contentsOf: package.appendingPathComponent("Schema/examples/\(name).json"))
        return try JSONDecoder().decode(WalletAgent.Input.self, from: data)
    }

    /// The text of the file `name` among `paths`.
    static func text(_ paths: [String], _ name: String) throws -> String {
        guard let path = paths.first(where: { $0.hasSuffix("/" + name) }) else {
            throw CocoaError(.fileNoSuchFile, userInfo: [NSFilePathErrorKey: name])
        }
        return try String(contentsOfFile: path, encoding: .utf8)
    }

    /// Every Swift file written, joined: what the scorecard's code facts are searched over.
    static func all(_ paths: [String]) throws -> String {
        try paths.filter { $0.hasSuffix(".swift") && FileManager.default.fileExists(atPath: $0) }.sorted()
            .map { try String(contentsOfFile: $0, encoding: .utf8) }.joined(separator: "\n")
    }

    /// The `code` items of the scorecard's `wallet` area (`.work/measure/task/seer/scorecard.json`), but B-wallet-11,
    /// the seeded mock wallet, which is `$mocks`' to write: each pattern must match somewhere in the Seer call's output.
    static let scorecard: [(id: String, all: [String])] = [
        ("B-wallet-7", [#"%\.4f cr"#, #"contentTransition\(\s*\.numericText\("#]),
        ("B-wallet-8", ["CREDIT BALANCE", "EARNINGS", #"(tracking|kerning)\(2\.5\)"#, #"arrow\.up\.circle\.fill"#, " available"]),
        ("B-wallet-9", [#"width:\s*150(\.0)?,\s*height:\s*120\b"#, #"width:\s*145(\.0)?,\s*height:\s*130\b"#]),
        ("B-wallet-10", ["Model Groups", "Credit Exchanges", "See All", "Transactions", "Cashout", "All Exchanges", "TOTAL EXCHANGES",
                         "Service Fee", "Total Cost", "Savings", "Loading wallet(…|\\.\\.\\.)"]),
    ]

    /// Every word the spec quotes for the Wallet screen and its sheets, the withdrawal's among them, as the code says
    /// it: a word that carries a value is checked by its words around the value (`"30.3700 cr available"` is
    /// ` available`).
    static let quoted = ["Wallet", "%.4f cr", "CREDIT BALANCE", "EARNINGS", "\"cr\"", " available", "Earned", "Spent", "Cashed Out",
                         "Model Groups", "documents", "Credit Exchanges", "See All", "Inference", "fee ", "Transactions", "Cashout",
                         "+ ", "Loading wallet…", "All Exchanges", "TOTAL EXCHANGES", " exchanges", "COST", "Documents", "Service Fee",
                         "Total Cost", "Savings", "\"-\\(", "Withdraw", "Coming soon", "No group earnings yet", "No inference exchanges yet",
                         "No cashouts recorded", "Wallet unavailable", "Connect Bank", "Connect a Bank",
                         "Your account details are encrypted\\nand never stored on our servers.", "Routing Number",
                         "9-digit routing number", "Account Number", "Account number", "Account Type", "Checking", "Savings",
                         "Continue", "\"Review\"", "\"Initiated\"", "AMOUNT", "Available: ", "\"25%\"", "\"50%\"", "\"Max\"",
                         "WITHDRAWAL AMOUNT", "\"To\"", "\"Routing\"", "Est. Arrival", "3–5 business days", "Confirm Withdrawal",
                         "Withdrawal Initiated", "Funds typically arrive in 3–5 business days.", "\"Done\"", "  ·  ", "•••• "]

    /// SeerKit as the Seer call reads it: the wallet and its lists, in a package of their own.
    static let seerKit = """
    import Foundation

    public struct Wallet: Codable, Sendable {
        public var balance: Double
        public var earned: Double
        public var spent: Double
        public var cashedOut: Double
        public var groups: [ModelEarning]
        public var exchanges: [CreditExchange]
        public var cashouts: [Cashout]

        public init(balance: Double, earned: Double, spent: Double, cashedOut: Double, groups: [ModelEarning],
                    exchanges: [CreditExchange], cashouts: [Cashout]) {
            self.balance = balance; self.earned = earned; self.spent = spent; self.cashedOut = cashedOut
            self.groups = groups; self.exchanges = exchanges; self.cashouts = cashouts
        }
    }

    public struct ModelEarning: Codable, Sendable {
        public var name: String
        public var documents: Int
        public var earnings: Double

        public init(name: String, documents: Int, earnings: Double) {
            self.name = name; self.documents = documents; self.earnings = earnings
        }
    }

    public struct CreditExchange: Codable, Sendable {
        public var id: String
        public var date: Date
        public var cost: Double
        public var fee: Double
        public var documents: Int
        public var savings: Double

        public init(id: String, date: Date, cost: Double, fee: Double, documents: Int, savings: Double) {
            self.id = id; self.date = date; self.cost = cost; self.fee = fee; self.documents = documents; self.savings = savings
        }
    }

    public struct Cashout: Codable, Sendable {
        public var id: String
        public var date: Date
        public var amount: Double

        public init(id: String, date: Date, amount: Double) {
            self.id = id; self.date = date; self.amount = amount
        }
    }
    """

    /// The reading app's own types, as the second example maps them.
    static let readingModels = """
    import Foundation

    struct Account {
        var points: Int
        var lifetimePoints: Int
        var spentPoints: Int
        var redeemed: Int
        var shelves: [Shelf]
        var purchases: [Purchase]
        var payouts: [Payout]
    }

    struct Shelf {
        var title: String
        var books: [String]
        var points: Int
    }

    struct Purchase {
        var bookTitle: String
        var boughtAt: String
        var price: Decimal
    }

    struct Payout {
        var paidAt: Date?
        var cents: Int
    }
    """
}
