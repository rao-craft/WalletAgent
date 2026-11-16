//  WHAT: The template of `WalletEyebrow.swift`.

extension Template {
    static let walletEyebrow = ##"""
    import SwiftUI

    /// A small tracked line over a number: `CREDIT BALANCE`.
    struct WalletEyebrow: View {
        let text: String

        var body: some View {
            Text(text)
                .font(.system(size: {{eyebrowSize}}, weight: .medium))
                .tracking({{eyebrowTracking}})
                .foregroundStyle(WalletLook.secondaryForeground)
                .lineLimit(1)
        }
    }

    #Preview {
        WalletEyebrow(text: WalletStrings.balanceEyebrow)
            .padding()
    }
    """##
}
