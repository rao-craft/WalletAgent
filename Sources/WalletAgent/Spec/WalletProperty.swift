//  WHAT: One thing a wallet view reads off an app's type: the word a mapping line names it by, the requirement it
//        is in the protocol, what it holds, and the sentence that documents it.

import Foundation

struct WalletProperty: Sendable, Equatable {
    /// The word on a mapping line: `balance`, `earnings`, `documents`.
    let key: String
    /// The protocol requirement: `walletBalance`. Namespaced, so an app's own `balance` never collides with it.
    let member: String
    let kind: WalletKind
    /// One sentence, the requirement's doc comment.
    let doc: String
    /// Other words a line may use for it.
    let aliases: [String]
    /// What a type that does not map it shows, when that is more than the kind's default (`walletEarned`).
    let fallback: String?

    init(_ key: String, _ member: String, _ kind: WalletKind, _ doc: String, aliases: [String] = [], fallback: String? = nil) {
        self.key = key; self.member = member; self.kind = kind; self.doc = doc; self.aliases = aliases; self.fallback = fallback
    }

    /// What the protocol's extension answers for a type that does not map it.
    var defaultValue: String { fallback ?? kind.defaultValue }
}
