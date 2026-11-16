//  WHAT: The template of `WalletTotalsView.swift`.

extension Template {
    static let walletTotalsView = ##"""
    import SwiftUI

    /// Three equal cells under the head: what was earned, spent and cashed out.
    struct WalletTotalsView: View {
        let earned: Double
        let spent: Double
        let cashedOut: Double

        var body: some View {
            HStack(spacing: 8) {
                cell(WalletFormat.amount(earned), WalletStrings.earned)
                cell(WalletFormat.amount(spent), WalletStrings.spent)
                cell(WalletFormat.amount(cashedOut), WalletStrings.cashedOut)
            }
        }

        private func cell(_ value: String, _ label: String) -> some View {
            VStack(alignment: .center, spacing: 4) {
                Text(value)
                    .font(.system(size: {{amountSize}}, design: .{{design}}))
                    .foregroundStyle(WalletLook.foreground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(.system(size: {{feeSize}}))
                    .foregroundStyle(WalletLook.secondaryForeground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(WalletLook.secondaryBackground.opacity({{cardOpacity}}))
            .clipShape(RoundedRectangle(cornerRadius: 4))
        }
    }

    #Preview {
        WalletTotalsView(earned: 31.2, spent: 9.65, cashedOut: 3.15)
            .padding()
    }
    """##
}
