//  WHAT: The template of `WalletGroupCard.swift`.

extension Template {
    static let walletGroupCard = ##"""
    import SwiftUI

    /// A group's small card in the sideways row: its name, how many documents it holds, and what it earned.
    struct WalletGroupCard<Item: WalletGroupRepresentable>: View {
        let group: Item

        var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(group.walletGroupName)
                    .font(WalletLook.note)
                    .foregroundStyle(WalletLook.foreground.opacity(0.6))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(WalletStrings.groupDocuments(group.walletGroupDocuments))
                    .font(WalletLook.note2)
                    .foregroundStyle(WalletLook.foreground.opacity(0.6))
                    .opacity(0.5)
                Spacer()
                Text(WalletFormat.amount(group.walletGroupEarnings))
                    .font(.system(size: {{amountSize}}, weight: .light, design: .{{design}}))
                    .foregroundStyle(WalletLook.foreground)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 24)
            .frame(width: {{groupCard.width}}, height: {{groupCard.height}})
            .modifier(WalletCardStyle())
        }
    }

    #Preview {
        WalletGroupCard(group: WalletSample.groups[0])
            .padding()
    }
    """##
}
