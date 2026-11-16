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
                    WalletHaptic.light()
                    action()
    //@endif
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "{{withdrawSymbol}}")
                            .font(.system(size: 14, weight: .light))
                        Text(WalletStrings.withdraw)
                            .font(.system(size: 16, weight: .semibold, design: .{{design}}))
                    }
                    .foregroundStyle(WalletLook.foreground.opacity(isEnabled ? 1 : 0.3))
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(WalletLook.foreground.opacity(isEnabled ? 1 : 0.3), lineWidth: 1))
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .disabled(!isEnabled)
    //@if withdraw.soon
                Text(WalletStrings.withdrawSoon)
                    .font(.system(size: 11, design: .{{design}}))
                    .italic()
                    .foregroundStyle(WalletLook.secondaryForeground)
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
