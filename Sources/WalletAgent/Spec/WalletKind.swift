//  WHAT: What a role property holds, and how a mapped value becomes it: its Swift type, its default, and the
//        `WalletValue` conversion a conformance wraps every right side in.
//  PIN:  EVERY RIGHT SIDE IS CONVERTED. An app's amount may be a `Double`, a `Decimal` or an `Int`, its documents a
//        count or a list of ids; `WalletValue` has an overload for each, so a bare path compiles whatever the field's
//        type.

import Foundation

enum WalletKind: Sendable, Equatable {
    case amount, count, text, optionalText, date
    /// A list of another role's values: a wallet's groups, exchanges or transactions.
    case list(WalletRole)

    /// The requirement's type in the protocol; a list names the role's associated type.
    var swiftType: String {
        switch self {
        case .amount: return "Double"
        case .count: return "Int"
        case .text: return "String"
        case .optionalText: return "String?"
        case .date: return "Date?"
        case .list(let role): return "[\(role.associatedType)]"
        }
    }

    /// What a type that does not map the property shows.
    var defaultValue: String {
        switch self {
        case .amount: return "0"
        case .count: return "0"
        case .text: return "\"\""
        case .optionalText, .date: return "nil"
        case .list: return "[]"
        }
    }

    /// The `WalletValue` function a mapped value goes through.
    var conversion: String {
        switch self {
        case .amount: return "amount"
        case .count: return "count"
        case .text: return "text"
        case .optionalText: return "optionalText"
        case .date: return "date"
        case .list: return "list"
        }
    }

    static let integers: Set<String> = ["Int", "Int8", "Int16", "Int32", "Int64", "UInt", "UInt8", "UInt16", "UInt32", "UInt64"]

    /// The field types `WalletValue`'s overloads for this kind take, optional or not; a list is read by its brackets.
    var takes: Set<String> {
        switch self {
        case .amount: return Self.integers.union(["Double", "Float", "CGFloat", "Decimal", "String"])
        case .count: return Self.integers.union(["Double"])
        case .text, .optionalText: return Self.integers.union(["String", "Substring", "UUID"])
        case .date: return ["Date", "String", "Double", "Int"]
        case .list: return []
        }
    }

    /// What `takes` says, in words, for a refusal.
    var takesInWords: String {
        switch self {
        case .amount: return "an amount (a Double, a Decimal, a Float, a whole number, or a String of digits)"
        case .count: return "a count (a whole number, or a list whose items are counted)"
        case .text, .optionalText: return "text (a String or a whole number)"
        case .date: return "a date (a Date, an ISO String, or seconds as a Double or an Int)"
        case .list(let role): return "a list of the type the `\(role.rawValue):` line maps"
        }
    }

    /// Whether a field written as `type` (as the app declares it) can be read as this kind.
    func accepts(_ type: String) -> Bool {
        let text = type.replacingOccurrences(of: " ", with: "")
        var base = text
        while base.hasSuffix("?") || base.hasSuffix("!") { base.removeLast() }
        switch self {
        case .list: return base.hasPrefix("[") && !base.contains(":")
        case .count: return takes.contains(base) || (base.hasPrefix("[") && !base.contains(":")) || base.hasPrefix("Set<")
        default: return takes.contains(base)
        }
    }

    /// A right side that says the property has nothing: what leaving it out already shows.
    func isNothing(_ value: String) -> Bool {
        let text = value.trimmingCharacters(in: .whitespaces)
        return ["nil", "[]", "\"\"", ".none"].contains(text) || text == defaultValue
    }
}
