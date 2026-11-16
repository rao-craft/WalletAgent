//  WHAT: The files that make an app's types the views' types: one extension a mapping line, each mapped property a
//        computed requirement that reads the type through `WalletValue`, and the wallet's list types named, so the
//        views know which type each of its lists holds.
//  PIN:  AN UNMAPPED PROPERTY IS NOT WRITTEN: the protocol's default answers for it, so a conformance holds only
//        what the line says. A list type is always named, the kit's own value when no line maps the role.

import Foundation

enum ConformanceEmitter {
    /// One file a mapping line, `<Type>+<Role>.swift`: `extension Wallet: WalletRepresentable { … }`. Written with
    /// the call's prefix already in the kit's names, so an app's own type is never renamed.
    static func emit(_ mappings: [Mapping], imports: [String], prefix: String) -> [(name: String, text: String)] {
        let types = Dictionary(mappings.map { ($0.role, $0.type) }, uniquingKeysWith: { first, _ in first })
        return mappings.map { line in
            var body: [String] = []
            if line.role == .wallet {
                for role in WalletRole.allCases where role != .wallet {
                    body.append("    typealias \(role.associatedType) = \(types[role] ?? role.itemType(prefix))")
                }
                if !line.assignments.isEmpty { body.append("") }
            }
            for assignment in line.assignments {
                let property = assignment.property
                body += getter(property.member, type: property.kind.swiftType, conversion: "\(prefix)Value.\(property.kind.conversion)", source: assignment.source)
            }
            var text = header(imports)
            text += [
                "/// \(article(line.type).capitalized) `\(line.type)` as the wallet views show \(line.role == .wallet ? "a wallet" : "a \(line.role.rawValue)").",
                "extension \(line.type): \(line.role.protocolName(prefix)) {",
            ]
            text += body
            text.append("}")
            return (name: "\(line.fileStem)+\(line.role.name).swift", text: text.joined(separator: "\n") + "\n")
        }
    }

    private static func header(_ imports: [String]) -> [String] {
        (["Foundation"] + imports.filter { $0 != "Foundation" }).map { "import \($0)" } + [""]
    }

    /// A computed requirement: a bare path read off the type, or an expression that names `value`; `conversion` is
    /// the prefixed function, `PointsValue.amount`.
    private static func getter(_ member: String, type: String, conversion: String, source: Mapping.Source) -> [String] {
        switch source {
        case .path(let path):
            return ["    var \(member): \(type) { \(conversion)(self.\(path)) }"]
        case .expression(let expression):
            guard expression.range(of: #"(?<![A-Za-z0-9_.])value(?![A-Za-z0-9_])"#, options: .regularExpression) != nil else {
                return ["    var \(member): \(type) { \(conversion)(\(expression)) }"]
            }
            return [
                "    var \(member): \(type) {",
                "        let value = self",
                "        return \(conversion)(\(expression))",
                "    }",
            ]
        }
    }

    private static func article(_ word: String) -> String {
        guard let first = word.first?.lowercased() else { return "a" }
        return "aeiou".contains(first) ? "an" : "a"
    }
}
