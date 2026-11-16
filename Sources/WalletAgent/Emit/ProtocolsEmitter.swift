//  WHAT: `WalletProtocols.swift`, made from the role table: one protocol a role with a default for every
//        requirement, then the kit's own value types, which an app with no type of its own for a role uses as they are.

import Foundation

enum ProtocolsEmitter {
    static func emit() -> String {
        var lines = ["import Foundation"]
        for role in WalletRole.allCases {
            let name = role.protocolName(KitCatalog.base)
            lines += [
                "",
                "/// \(role.doc)",
                "///",
                "/// Every requirement has a default, so a type maps only what it has. The names start with `wallet` so they",
                "/// never meet the type's own properties.",
                "protocol \(name) {",
            ]
            if role == .wallet {
                for list in WalletRole.allCases where list != .wallet {
                    lines.append("    associatedtype \(list.associatedType): \(list.protocolName(KitCatalog.base)) = \(list.itemType(KitCatalog.base))")
                }
            }
            for property in role.properties {
                lines.append("    /// \(property.doc)")
                lines.append("    var \(property.member): \(property.kind.swiftType) { get }")
            }
            lines += ["}", "", "extension \(name) {"]
            for property in role.properties {
                lines.append("    var \(property.member): \(property.kind.swiftType) { \(property.defaultValue) }")
            }
            lines.append("}")
        }
        for role in WalletRole.allCases {
            let item = role.itemType(KitCatalog.base)
            let stored = role.properties.filter { $0.fallback == nil }
            lines += [
                "",
                "/// \(role == .wallet ? "A wallet" : "A \(role.rawValue)") of the kit's own, for an app with no type to map: "
                    + "`\(item)(" + stored.prefix(2).map { "\($0.key): …" }.joined(separator: ", ") + ")`.",
                "struct \(item): \(role.protocolName(KitCatalog.base)) {",
            ]
            for property in stored {
                lines.append("    var \(property.key): \(itemType(property.kind)) = \(property.kind.defaultValue)")
            }
            lines.append("")
            for property in stored {
                lines.append("    var \(property.member): \(property.kind.swiftType) { \(property.key) }")
            }
            lines.append("}")
        }
        return TemplateRender.tidy(lines)
    }

    /// A stored property's type on the kit's own value: a list holds the kit's own values of its role.
    private static func itemType(_ kind: WalletKind) -> String {
        if case .list(let role) = kind { return "[\(role.itemType(KitCatalog.base))]" }
        return kind.swiftType
    }
}
