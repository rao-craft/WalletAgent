//  WHAT: The four roles an app's type can take for the wallet views (the wallet itself, a group that earned, an
//        exchange that spent, a transaction that cashed out) and everything each role's views read. The one source
//        of the protocols' requirements, of what a mapping line may name, and of the guide's word list.
//  PIN:  ONE TABLE. The protocol file's template, the conformances and the tests all read these lists, so a
//        property added here is a requirement, a mapping word and a default at once (a test holds the template to it).

import Foundation

enum WalletRole: String, CaseIterable, Sendable {
    case wallet, group, exchange, transaction

    /// The role's name in Swift: `Group`.
    var name: String { rawValue.prefix(1).uppercased() + rawValue.dropFirst() }

    /// The protocol an app's type conforms to, under the call's prefix: `WalletGroupRepresentable`.
    func protocolName(_ prefix: String) -> String {
        self == .wallet ? prefix + "Representable" : prefix + name + "Representable"
    }

    /// The kit's own value type for the role, when the app has none: `WalletGroupItem`.
    func itemType(_ prefix: String) -> String {
        prefix + (self == .wallet ? "" : name) + "Item"
    }

    /// The wallet protocol's associated type its list of this role is made of: `GroupValue`.
    var associatedType: String { name + "Value" }

    /// Other words a mapping line may start with.
    var aliases: [String] {
        switch self {
        case .wallet: return ["account", "balance", "credits", "purse"]
        case .group: return ["model", "collection", "earning", "source"]
        case .exchange: return ["spend", "charge", "usage", "inference"]
        case .transaction: return ["cashout", "payout", "withdrawal", "movement"]
        }
    }

    /// What the role is, for the protocol's doc comment.
    var doc: String {
        switch self {
        case .wallet: return "A wallet as the wallet views show it: what it holds, what it earned, spent and cashed out, and the lists behind them."
        case .group: return "A group as the wallet views show it: a card in the sideways row of what earned."
        case .exchange: return "An exchange as the wallet views show it: credits spent on one thing, on one day."
        case .transaction: return "A transaction as the wallet views show it: credits cashed out, on one day."
        }
    }

    var properties: [WalletProperty] {
        switch self {
        case .wallet:
            return [
                .init("balance", "walletBalance", .amount, "What the wallet holds now.", aliases: ["credits", "total", "held"]),
                .init("earned", "walletEarned", .amount, "Everything it has earned.", aliases: ["totalEarned", "totalEarnings"]),
                .init("spent", "walletSpent", .amount, "Everything it has spent.", aliases: ["totalSpent"]),
                .init("cashedOut", "walletCashedOut", .amount, "Everything it has cashed out.", aliases: ["cashed", "cashout", "withdrawn", "paidOut", "totalCashedOut"]),
                .init("earnings", "walletEarnings", .amount, "The earnings the head shows; what it earned when left out.", aliases: ["income"], fallback: "walletEarned"),
                .init("available", "walletAvailable", .amount, "What can be cashed out; earned less cashed out when left out.", aliases: ["availableBalance", "withdrawable"], fallback: "walletEarned - walletCashedOut"),
                .init("groups", "walletGroups", .list(.group), "The groups that earned, one card each.", aliases: ["models", "collections", "earningsByGroup", "sources"]),
                .init("exchanges", "walletExchanges", .list(.exchange), "What was spent, one exchange each.", aliases: ["spends", "charges", "usage"]),
                .init("transactions", "walletTransactions", .list(.transaction), "What was cashed out, one transaction each.", aliases: ["cashouts", "payouts", "withdrawals", "movements"]),
            ]
        case .group:
            return [
                .init("name", "walletGroupName", .text, "Its name, at the top of its card.", aliases: ["title", "label"]),
                .init("documents", "walletGroupDocuments", .count, "How many documents it holds: a count, or a list that is counted.", aliases: ["count", "items", "docs", "documentCount"]),
                .init("earnings", "walletGroupEarnings", .amount, "What it earned, at the bottom of its card.", aliases: ["earned", "amount", "credits"]),
            ]
        case .exchange:
            return [
                .init("title", "walletExchangeTitle", .optionalText, "What it was for; the strings' `exchange.title` when left out.", aliases: ["name", "kind", "label"]),
                .init("date", "walletExchangeDate", .date, "When it was made.", aliases: ["createdAt", "timestamp", "at", "day"]),
                .init("cost", "walletExchangeCost", .amount, "What it cost, net.", aliases: ["netCost", "amount", "spent", "price"]),
                .init("fee", "walletExchangeFee", .amount, "The service fee within it.", aliases: ["serviceFee", "serviceCharge", "charge"]),
                .init("documents", "walletExchangeDocuments", .count, "How many documents it used: a count, or a list that is counted.", aliases: ["documentIds", "docs", "documentCount"]),
                .init("savings", "walletExchangeSavings", .amount, "What it saved.", aliases: ["saved", "saving", "discount"]),
                .init("total", "walletExchangeTotal", .amount, "What it would have cost; cost and savings together when left out.", aliases: ["totalCost", "gross"], fallback: "walletExchangeCost + walletExchangeSavings"),
            ]
        case .transaction:
            return [
                .init("title", "walletTransactionTitle", .optionalText, "What it was; the strings' `transaction.title` when left out.", aliases: ["name", "kind", "label"]),
                .init("date", "walletTransactionDate", .date, "When it was made.", aliases: ["createdAt", "timestamp", "at", "day"]),
                .init("amount", "walletTransactionAmount", .amount, "How much it moved.", aliases: ["value", "credits", "sum"]),
            ]
        }
    }

    /// The property a mapping line's word names, by its key or an alias, any case.
    func property(named word: String) -> WalletProperty? {
        let lower = word.lowercased()
        return properties.first { $0.key.lowercased() == lower } ?? properties.first { $0.aliases.contains { $0.lowercased() == lower } }
    }

    /// The role a mapping line's first word names, by its name or an alias, any case.
    static func named(_ word: String) -> WalletRole? {
        let lower = word.lowercased()
        return WalletRole(rawValue: lower) ?? allCases.first { $0.aliases.contains(lower) }
    }
}
