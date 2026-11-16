//  WHAT: The template of `WalletHeroView.swift`: the balance and the earnings, side by side.

extension Template {
    static let walletHeroView = ##"""
    import SwiftUI

    /// The wallet's head, two equal columns with a thin rule between: the balance, wrapping when the column is too
    /// narrow for it, with its unit on its last line (in thousands from a thousand, in millions from a million); the
    /// earnings, right-aligned, with what can be cashed out in green. Both amounts roll to a new value.
    struct WalletHeroView: View {
        let balance: Double
        let earnings: Double
        let available: Double

        var body: some View {
            let parts = WalletFormat.balance(balance)
            HStack(alignment: .top, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    WalletEyebrow(text: WalletStrings.balanceEyebrow)
                    HStack(alignment: .lastTextBaseline, spacing: 3) {
    //@if unitLeads
                        unit(parts.unit)
    //@endif
                        Text(parts.number)
                            .font(.system(size: {{balanceSize}}, weight: .light, design: .{{design}}))
                            .foregroundStyle(WalletLook.foreground)
                            .contentTransition(.numericText())
                            .animation({{amountAnimation}}, value: balance)
    //@if !unitLeads
                        unit(parts.unit)
    //@endif
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(WalletLook.foreground.opacity(0.12))
                    .frame(width: 1)
                    .padding(.vertical, 4)

                VStack(alignment: .trailing, spacing: 8) {
                    WalletEyebrow(text: WalletStrings.earningsEyebrow)
                    Text(WalletFormat.amount(earnings))
                        .font(.system(size: {{earningsSize}}, weight: .light, design: .{{design}}))
                        .foregroundStyle(WalletLook.foreground)
                        .contentTransition(.numericText())
                        .animation({{amountAnimation}}, value: earnings)
                    if available > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "{{availableSymbol}}")
                                .font(.system(size: {{availableSymbolSize}}))
                            Text(WalletStrings.available(WalletFormat.amount(available)))
                                .font(.system(size: {{availableSize}}, weight: .regular, design: .{{design}}))
                        }
                        .foregroundStyle(WalletLook.positive)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .frame(maxWidth: .infinity)
        }

        private func unit(_ text: String) -> some View {
            Text(text)
                .font(.system(size: {{unitSize}}, weight: .light, design: .{{design}}))
                .foregroundStyle(WalletLook.secondaryForeground)
        }
    }

    #Preview {
        WalletHeroView(balance: 86.62, earnings: 31.2, available: 28.05)
            .padding()
    }
    """##
}
