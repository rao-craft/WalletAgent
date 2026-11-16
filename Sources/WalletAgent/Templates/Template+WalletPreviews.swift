//  WHAT: The template of `WalletPreviews.swift`: the sample wallet every preview draws.

extension Template {
    static let walletPreviews = ##"""
    import Foundation

    /// A small wallet for the views' previews, made of the kit's own values, so every preview works before the app
    /// maps its own types.
    enum WalletSample {
        static var wallet: WalletItem {
            WalletItem(balance: 18.4, earned: 31.2, spent: 9.65, cashedOut: 3.15,
                       groups: groups, exchanges: exchanges, transactions: transactions)
        }

        static var groups: [WalletGroupItem] {
            [
                WalletGroupItem(name: "Travel", documents: 12, earnings: 14.6),
                WalletGroupItem(name: "Poetry", documents: 7, earnings: 9.8),
                WalletGroupItem(name: "Gardening", documents: 1, earnings: 6.8),
            ]
        }

        static var exchanges: [WalletExchangeItem] {
            (0..<4).map { day in
                WalletExchangeItem(date: Date(timeIntervalSince1970: 1_790_000_000 - Double(day) * 86_400),
                                   cost: 0.12 + Double(day) * 0.03, fee: 0.02, documents: 2, savings: 0.04)
            }
        }

        static var transactions: [WalletTransactionItem] {
            [
                WalletTransactionItem(date: Date(timeIntervalSince1970: 1_789_000_000), amount: 2.15),
                WalletTransactionItem(date: Date(timeIntervalSince1970: 1_787_000_000), amount: 1),
            ]
        }
    }
    """##
}
