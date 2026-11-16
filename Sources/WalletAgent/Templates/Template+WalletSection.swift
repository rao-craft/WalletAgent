//  WHAT: The template of `WalletSection.swift`.

extension Template {
    static let walletSection = ##"""
    import SwiftUI

    /// One block of the wallet: its heading, a trailing button when there is one, and what it holds.
    struct WalletSection<Content: View>: View {
        let title: String
        var trailing: String?
        var onTrailing: (@MainActor () -> Void)?
        let content: Content

        init(title: String, trailing: String? = nil, onTrailing: (@MainActor () -> Void)? = nil, @ViewBuilder content: () -> Content) {
            self.title = title
            self.trailing = trailing
            self.onTrailing = onTrailing
            self.content = content()
        }

        var body: some View {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .center) {
                    Text(title)
                        .font(WalletLook.heading)
                        .foregroundStyle(WalletLook.foreground.opacity(0.75))
                    Spacer(minLength: 8)
                    if let trailing, let onTrailing {
                        Button {
                            WalletHaptic.light()
                            onTrailing()
                        } label: {
                            Text(trailing)
                                .font(.system(size: {{seeAllSize}}, design: .{{design}}))
                                .foregroundStyle(WalletLook.accent)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, WalletLook.gutter)
                .padding(.top, 24)
                .padding(.bottom, 12)
                content
            }
            .padding(.bottom, 24)
        }
    }

    #Preview {
        WalletSection(title: WalletStrings.exchangesTitle, trailing: WalletStrings.exchangesSeeAll, onTrailing: {}) {
            Text(WalletStrings.exchangesEmpty)
                .padding(.horizontal, WalletLook.gutter)
        }
    }
    """##
}
