//  WHAT: The template of `WalletExchangeRow.swift`.

extension Template {
    static let walletExchangeRow = ##"""
    import SwiftUI

    /// An exchange as a full-width small card in the list of them all: what it was over its day; its net cost over
    /// its fee.
    struct WalletExchangeRow<Item: WalletExchangeRepresentable>: View {
        let exchange: Item

        var body: some View {
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(exchange.walletExchangeTitle ?? WalletStrings.exchangeTitle)
                        .font(WalletLook.note)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                    Text(WalletFormat.day(exchange.walletExchangeDate))
                        .font(WalletLook.note2)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                        .opacity(0.5)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(WalletFormat.amount(exchange.walletExchangeCost))
                        .font(.system(size: {{amountSize}}, weight: .light, design: .{{design}}))
                        .foregroundStyle(WalletLook.foreground)
                    if exchange.walletExchangeFee > 0 {
                        Text(WalletStrings.exchangeFee(WalletFormat.amount(exchange.walletExchangeFee)))
                            .font(.system(size: {{feeSize}}, design: .{{design}}))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity)
            .modifier(WalletCardStyle())
        }
    }

    #Preview {
        WalletExchangeRow(exchange: WalletSample.exchanges[0])
            .padding()
    }
    """##
}
