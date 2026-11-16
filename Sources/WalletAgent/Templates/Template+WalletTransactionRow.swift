//  WHAT: The template of `WalletTransactionRow.swift`.

extension Template {
    static let walletTransactionRow = ##"""
    import SwiftUI

    /// A transaction's row: what it was over its day; its amount in green.
    struct WalletTransactionRow<Item: WalletTransactionRepresentable>: View {
        let transaction: Item

        var body: some View {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(transaction.walletTransactionTitle ?? WalletStrings.transactionTitle)
                        .font(WalletLook.note)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                    Text(WalletFormat.day(transaction.walletTransactionDate))
                        .font(WalletLook.note2)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                        .opacity(0.5)
                }
                Spacer()
                Text(WalletStrings.transactionAmount(WalletFormat.amount(transaction.walletTransactionAmount)))
                    .font(.system(size: {{amountSize}}, weight: .light, design: .{{design}}))
                    .foregroundStyle(WalletLook.positive)
            }
            .padding(.horizontal, WalletLook.gutter)
            .padding(.vertical, 16)
        }
    }

    #Preview {
        WalletTransactionRow(transaction: WalletSample.transactions[0])
    }
    """##
}
