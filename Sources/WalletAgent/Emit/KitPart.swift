//  WHAT: One file of the kit a call can write: its template (or the emitter that makes it), the types it declares,
//        and when it is written at all.

import Foundation

struct KitPart: Sendable {
    /// The file's name without `.swift`, before the call's prefix: `WalletHeroView`.
    let name: String
    /// The types it declares, which the call's prefix renames.
    let types: [String]
    /// The template; empty for a file an emitter makes from the call (`WalletLook`, `WalletStrings`, …).
    let template: String
    /// A template flag without which it is never written: `withdraw.on`.
    let flag: String?
    /// Whether it is a view the answer lists.
    let isView: Bool

    init(_ name: String, types: [String]? = nil, view: Bool = true, flag: String? = nil, _ template: String = "") {
        self.name = name; self.types = types ?? [name]; self.template = template; self.flag = flag; self.isView = view
    }
}
