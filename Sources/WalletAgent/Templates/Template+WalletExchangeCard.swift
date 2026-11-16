//  WHAT: The template of `WalletExchangeCard.swift`.

extension Template {
    static let walletExchangeCard = ##"""
    import SwiftUI

    /// An exchange's small card in the sideways row: what it was, its day, its net cost and the fee within it. A tap
    /// opens it.
    struct WalletExchangeCard<Item: WalletExchangeRepresentable>: View {
        let exchange: Item
        let open: @MainActor () -> Void

        var body: some View {
            Button {
                WalletHaptic.light()
                open()
            } label: {
                VStack(alignment: .leading, spacing: 8) {
                    Text(exchange.walletExchangeTitle ?? WalletStrings.exchangeTitle)
                        .font(WalletLook.note)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                    Text(WalletFormat.day(exchange.walletExchangeDate))
                        .font(WalletLook.note2)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                        .opacity(0.5)
                    Spacer()
                    VStack(alignment: .leading, spacing: 2) {
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
                .padding(.vertical, 24)
                .frame(width: {{exchangeCard.width}}, height: {{exchangeCard.height}})
                .modifier(WalletCardStyle())
            }
            .buttonStyle(.plain)
        }
    }

    #Preview {
        WalletExchangeCard(exchange: WalletSample.exchanges[0], open: {})
            .padding()
    }
    """##
}
