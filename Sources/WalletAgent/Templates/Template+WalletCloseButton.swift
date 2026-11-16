//  WHAT: The template of `WalletCloseButton.swift`: the close mark and the bar every wallet screen wears.

extension Template {
    static let walletCloseButton = ##"""
    import SwiftUI

    /// The close mark a bar ends with.
    struct WalletCloseButton: View {
        let action: @MainActor () -> Void

        var body: some View {
            Button {
                WalletHaptic.light()
                action()
            } label: {
                Image(systemName: "xmark")
                    .symbolRenderingMode(.hierarchical)
            }
            .accessibilityLabel(WalletStrings.close)
        }
    }

    /// A screen's bar: its title inline in the look's title, and the close mark trailing when there is something to
    /// close. The app's own bar items stay where the app put them.
    struct WalletSheetBar: ViewModifier {
        let title: String
        var close: (@MainActor () -> Void)?

        func body(content: Content) -> some View {
            let titled = content
                .navigationTitle(title)
                #if os(iOS)
                .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(title)
                            .font(WalletLook.title)
                            .foregroundStyle(WalletLook.foreground.opacity(0.75))
                            .lineLimit(1)
                    }
                }
            if let close {
                titled.toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) {
                        WalletCloseButton(action: close)
                    }
                    #else
                    ToolbarItem(placement: .primaryAction) {
                        WalletCloseButton(action: close)
                    }
                    #endif
                }
            } else {
                titled
            }
        }
    }

    #Preview {
        NavigationStack {
            Text(WalletStrings.title)
                .modifier(WalletSheetBar(title: WalletStrings.title, close: {}))
        }
    }
    """##
}
