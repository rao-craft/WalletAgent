//  WHAT: What a call writes: the parts its flags allow, the template flags, and the value of every `{{key}}`.

import Foundation

struct KitPlan: Sendable {
    let withdraw: WalletWithdraw
    /// The tuning, every key: the call's value or the default, made regular.
    let tuning: [String: String]
    /// The launch states some launch line opens.
    let launched: Set<String>
    /// Whether the amount's unit comes before its number (`$%.2f`).
    let unitLeads: Bool

    /// The parts written, in the catalog's order.
    var parts: [KitPart] { KitCatalog.parts.filter { $0.flag.map { flags.contains($0) } ?? true } }

    /// `withdraw` (a button of either kind), `withdraw.on` or `withdraw.soon`; `launch.X` for each state a line
    /// opens; `unitLeads`.
    var flags: Set<String> {
        var flags: Set<String> = Set(launched.map { "launch." + $0 })
        if withdraw != .off { flags.insert("withdraw") }
        flags.insert("withdraw." + withdraw.rawValue)
        if unitLeads { flags.insert("unitLeads") }
        return flags
    }

    /// Each template placeholder's text: `groupCard.width` is `150`, `material` is `regularMaterial`.
    var values: [String: String] {
        var values: [String: String] = [:]
        for key in WalletTables.tuning {
            for (name, value) in TuningLine.placeholders(key, value: tuning[key.key] ?? key.value) { values[name] = value }
        }
        return values
    }

    /// The view types written, the root first.
    var views: [String] {
        let views = parts.filter(\.isView).map(\.name)
        return ["WalletView"] + views.filter { $0 != "WalletView" }
    }
}
