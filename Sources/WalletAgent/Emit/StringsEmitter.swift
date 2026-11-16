//  WHAT: `WalletStrings.swift`: every word the views say, one static member a key, the call's words where a
//        `strings` line sets them and the kit's own elsewhere. A word that says something (`{amount} available`) is
//        a function of it; a key with a `.one` form says one with it.

import Foundation

enum StringsEmitter {
    static func emit(_ set: [String: String], flags: Set<String>) -> String {
        var lines = [
            "import Foundation",
            "",
            "/// Every word the wallet views say. The call's `strings` lines set them; the rest are the kit's own.",
            "enum WalletStrings {",
        ]
        let keys = WalletTables.strings.filter { key in key.part.map { flags.contains($0) } ?? true }
        func text(_ key: StringKey) -> String { set[key.key] ?? key.text }
        for key in keys where !key.isSingular {
            lines.append("    /// \(key.doc)")
            let placeholders = key.placeholders
            if placeholders.isEmpty {
                lines.append("    static var \(key.member): String { \(SwiftName.literal(text(key))) }")
                continue
            }
            let parameters = placeholders.map { "_ \($0): \($0 == "amount" ? "String" : "Int")" }.joined(separator: ", ")
            let many = SwiftName.literal(text(key), placeholders: placeholders)
            if let one = keys.first(where: { $0.key == key.key + ".one" }), placeholders.contains("count") {
                let single = SwiftName.literal(text(one), placeholders: placeholders)
                lines.append("    static func \(key.member)(\(parameters)) -> String { count == 1 ? \(single) : \(many) }")
            } else {
                lines.append("    static func \(key.member)(\(parameters)) -> String { \(many) }")
            }
        }
        // The balance's number and its unit, cut from `amount`: `%.4f` and `cr`.
        let parts = amountParts(text(WalletTables.strings.first { $0.key == "amount" }!))
        lines.append("    /// The balance's number: `amount` without its unit.")
        lines.append("    static var balanceNumber: String { \(SwiftName.literal(parts.number)) }")
        lines.append("    /// The unit beside the balance: `amount` without its number.")
        lines.append("    static var balanceUnit: String { \(SwiftName.literal(parts.unit)) }")
        lines.append("}")
        return TemplateRender.tidy(lines)
    }

    /// `%.4f cr` cut into `%.4f` and `cr`, and whether the unit comes first (`$%.2f`).
    static func amountParts(_ amount: String) -> (number: String, unit: String, leads: Bool) {
        guard let range = amount.range(of: #"%[0-9]*(\.[0-9]+)?f"#, options: .regularExpression) else { return (amount, "", false) }
        let before = String(amount[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        let after = String(amount[range.upperBound...]).trimmingCharacters(in: .whitespaces)
        let unit = (before.isEmpty ? after : before).replacingOccurrences(of: "%%", with: "%")
        return (String(amount[range]), unit, !before.isEmpty)
    }
}
