import Foundation

/// What a run says as it goes.
public enum WalletFrame: Sendable {
    /// The call was read: how many mapping lines, and how many views it writes.
    case read(mappings: Int, views: Int)
    /// The files are written.
    case written(WalletResult)

    public var result: WalletResult? {
        if case .written(let result) = self { return result }
        return nil
    }
}
