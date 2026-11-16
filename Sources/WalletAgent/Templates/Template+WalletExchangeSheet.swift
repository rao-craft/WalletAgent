//  WHAT: The template of `WalletExchangeSheet.swift`: one exchange, opened from a card or a row.

extension Template {
    static let walletExchangeSheet = ##"""
    import SwiftUI

    /// One exchange: its net cost and when it was made, then a small card of the documents it used and, when it
    /// carried a fee, the fee, what it would have cost and what it saved.
    struct WalletExchangeSheet<Item: WalletExchangeRepresentable>: View {
        let exchange: Item

        @Environment(\.dismiss) private var dismiss

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            WalletEyebrow(text: WalletStrings.exchangeEyebrow)
                            Text(WalletFormat.amount(exchange.walletExchangeCost))
                                .font(.system(size: {{balanceSize}}, weight: .light, design: .{{design}}))
                                .foregroundStyle(WalletLook.foreground)
                            Text(WalletFormat.moment(exchange.walletExchangeDate))
                                .font(.system(size: {{seeAllSize}}, design: .{{design}}))
                                .foregroundStyle(WalletLook.secondaryForeground)
                                .padding(.top, 2)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                        .padding(.horizontal, WalletLook.gutter)

                        Divider()
                            .padding(.horizontal, WalletLook.gutter)

                        VStack(spacing: 0) {
                            row(WalletStrings.exchangeDocuments, "\(exchange.walletExchangeDocuments)")
                            if exchange.walletExchangeFee > 0 {
                                Divider().padding(.horizontal, 16)
                                row(WalletStrings.exchangeServiceFee, WalletFormat.amount(exchange.walletExchangeFee))
                                Divider().padding(.horizontal, 16)
                                row(WalletStrings.exchangeTotal, WalletFormat.amount(exchange.walletExchangeTotal))
                                Divider().padding(.horizontal, 16)
                                row(WalletStrings.exchangeSavings, WalletStrings.exchangeSaved(WalletFormat.amount(exchange.walletExchangeSavings)))
                            }
                        }
                        .modifier(WalletCardStyle())
                        .padding(.horizontal, WalletLook.gutter)
                        .padding(.vertical, 24)
                    }
                }
                .modifier(WalletSheetBar(title: exchange.walletExchangeTitle ?? WalletStrings.exchangeTitle, close: { dismiss() }))
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.{{material}})
        }

        private func row(_ label: String, _ value: String) -> some View {
            HStack {
                Text(label)
                    .foregroundStyle(WalletLook.foreground.opacity(0.6))
                    .opacity(0.55)
                Spacer()
                Text(value)
                    .foregroundStyle(WalletLook.foreground.opacity(0.6))
            }
            .font(WalletLook.note2)
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
        }
    }

    #Preview {
        WalletExchangeSheet(exchange: WalletSample.exchanges[0])
    }
    """##
}
