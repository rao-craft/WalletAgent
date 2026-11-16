//  WHAT: The template of `WalletExchangesSheet.swift`: the sheet behind See All.

extension Template {
    static let walletExchangesSheet = ##"""
    import SwiftUI

    /// Every exchange under how many there are, as full-width small cards: the sheet behind See All. A tap opens one.
    /// `exchanges` come in the order shown, newest first.
    struct WalletExchangesSheet<Item: WalletExchangeRepresentable>: View {
        let exchanges: [Item]

        @Environment(\.dismiss) private var dismiss
        @State private var opened: WalletIndex?

        var body: some View {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            WalletEyebrow(text: WalletStrings.allExchangesEyebrow)
                            Text(WalletStrings.allExchangesCount(exchanges.count))
                                .font(.system(size: {{balanceSize}}, weight: .light, design: .{{design}}))
                                .foregroundStyle(WalletLook.foreground)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                        .padding(.horizontal, WalletLook.gutter)

                        Divider()
                            .padding(.horizontal, WalletLook.gutter)

                        LazyVStack(spacing: 12) {
                            ForEach(Array(exchanges.enumerated()), id: \.offset) { index, exchange in
                                Button {
                                    WalletHaptic.light()
                                    opened = WalletIndex(id: index)
                                } label: {
                                    WalletExchangeRow(exchange: exchange)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, WalletLook.gutter)
                        .padding(.vertical, 12)
                    }
                }
                .modifier(WalletSheetBar(title: WalletStrings.allExchangesTitle, close: { dismiss() }))
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.{{material}})
            .sheet(item: $opened) { index in
                if exchanges.indices.contains(index.id) {
                    WalletExchangeSheet(exchange: exchanges[index.id])
                }
            }
        }
    }

    #Preview {
        WalletExchangesSheet(exchanges: WalletSample.exchanges)
    }
    """##
}
