//  WHAT: `WalletLook.swift`: one static member a look role, the app's own name for it when a `look` line maps it,
//        else the system's value, so the views build in any app.

import Foundation

enum LookEmitter {
    static func emit(_ mapped: [String: String]) -> String {
        var lines = [
            "import SwiftUI",
            "",
            "/// How the wallet views look: each role is the app's own name for it when the call maps it, else the system's.",
            "enum WalletLook {",
        ]
        for role in WalletTables.look {
            lines.append("    /// \(role.doc)")
            let value = mapped[role.key] ?? role.fallback
            if value.contains("\n") {
                lines.append("    static var \(role.key): \(role.kind.rawValue) {")
                lines += value.split(separator: "\n").map { "        " + $0 }
                lines.append("    }")
            } else {
                lines.append("    static var \(role.key): \(role.kind.rawValue) { \(value) }")
            }
        }
        lines.append("}")
        return TemplateRender.tidy(lines)
    }
}
