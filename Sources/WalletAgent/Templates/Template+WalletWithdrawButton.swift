//  WHAT: The template of `WalletWithdrawButton.swift`: written with `withdraw: on` (it opens the withdrawal) or
//        `soon` (it is faded, with "Coming soon" under it).

extension Template {
    static let walletWithdrawButton = ##"""
    import SwiftUI

    /// The withdraw button: outlined, full width, faded while it cannot act.
    struct WalletWithdrawButton: View {
    //@if withdraw.on
        let enabled: Bool
        let action: @MainActor () -> Void
    //@endif

        var body: some View {
            VStack(spacing: 8) {
                Button {
    //@if withdraw.on
                    action()
                    WalletHaptic.light()
    //@endif
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "{{withdrawSymbol}}")
                            .font(.system(size: 14, weight: .light))
                        Text(WalletStrings.withdraw)
                            .font(.system(size: 16, weight: .semibold, design: .{{design}}))
                    }
                    .modifier(WalletOutlined(enabled: isEnabled))
                }
                .disabled(!isEnabled)
    //@if withdraw.soon
                Text(WalletStrings.withdrawSoon)
                    .font(.system(size: 11, weight: .regular, design: .{{design}}))
                    .foregroundStyle(WalletLook.secondaryForeground)
                    .italic()
    //@endif
            }
        }

        private var isEnabled: Bool {
    //@if withdraw.on
            enabled
    //@else
            false
    //@endif
        }
    }

    #Preview {
    //@if withdraw.on
        WalletWithdrawButton(enabled: true, action: {})
            .padding()
    //@else
        WalletWithdrawButton()
            .padding()
    //@endif
    }
    """##
}
