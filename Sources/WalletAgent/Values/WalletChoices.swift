import Foundation

/// Whether the wallet offers a withdrawal.
public enum WalletWithdraw: String, Codable, Sendable, CaseIterable {
    /// A Withdraw button, drawn when the app passes `withdraw:`, opening the withdrawal sheet (bank, amount,
    /// review, done): the default.
    case on
    /// A Withdraw button that is never enabled, with "Coming soon" under it. The withdrawal sheet is written only for
    /// a `withdraw` launch line, which opens it.
    case soon
    /// No button and no sheet: nothing of a withdrawal is written.
    case off
}
