//  WHAT: The template of `WalletSupport.swift`: how amounts and dates read, the taps, the index a sheet opens by,
//        and the looks the views repeat: the small card, a detail row, the outlined button.

extension Template {
    static let walletSupport = ##"""
    import SwiftUI
    #if canImport(UIKit)
    import UIKit
    #endif

    /// How the wallet views write amounts and dates.
    enum WalletFormat {
        /// An amount as `WalletStrings.amount` reads.
        static func amount(_ value: Double) -> String { String(format: WalletStrings.amount, value) }

        /// The balance's number alone, without its unit.
        static func number(_ value: Double) -> String { String(format: WalletStrings.balanceNumber, value) }

        /// The balance as the head shows it, its number and its unit: in thousands from a thousand (`1.25` `K cr`),
        /// in millions from a million.
        static func balance(_ value: Double) -> (number: String, unit: String) {
            switch value {
            case 1_000_000...:
                return (String(format: "%.2f", value / 1_000_000), WalletStrings.balanceMillions)
            case 1_000...:
                return (String(format: "%.2f", value / 1_000), WalletStrings.balanceThousands)
            default:
                return (number(value), WalletStrings.balanceUnit)
            }
        }

        /// A day as the system writes it: `Nov 13, 2026`.
        static func day(_ date: Date?) -> String {
            guard let date else { return "" }
            return date.formatted(date: .abbreviated, time: .omitted)
        }

        /// A day and its time: `Nov 13, 2026 at 9:41 AM`.
        static func moment(_ date: Date?) -> String {
            guard let date else { return "" }
            return date.formatted(date: .abbreviated, time: .shortened)
        }

        /// `items` newest first by `date`; those with no date keep their order, after the rest.
        static func newestFirst<Item>(_ items: [Item], date: (Item) -> Date?) -> [Item] {
            items.enumerated().sorted { first, second in
                switch (date(first.element), date(second.element)) {
                case let (one?, other?): return one != other ? one > other : first.offset < second.offset
                case (.some, nil): return true
                case (nil, .some): return false
                case (nil, nil): return first.offset < second.offset
                }
            }.map { $0.element }
        }
    }

    /// The light tap felt on every control that acts.
    enum WalletHaptic {
        @MainActor static func light() {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
        }
    //@if withdraw.on

        /// The firmer tap of sending a withdrawal.
        @MainActor static func medium() {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            #endif
        }
    //@endif
    }

    /// Which item a sheet is open for.
    struct WalletIndex: Identifiable, Hashable {
        let id: Int
    }

    /// The small card: the secondary background at the card's opacity, rounded, with a 1 pt border.
    struct WalletCardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(WalletLook.secondaryBackground.opacity({{cardOpacity}}))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(WalletLook.foreground.opacity({{cardBorder}}), lineWidth: 1))
        }
    }

    /// A row of a small card of details: its label faded, its value trailing.
    struct WalletDetailRow: View {
        let label: String
        let value: String

        var body: some View {
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
    //@if withdraw

    /// The outlined look of the withdrawal's buttons: full width, 52 high, a 1 pt rounded border, faded while the
    /// button cannot act.
    struct WalletOutlined: ViewModifier {
        let enabled: Bool

        func body(content: Content) -> some View {
            content
                .foregroundStyle(WalletLook.foreground.opacity(enabled ? 1 : 0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(RoundedRectangle(cornerRadius: 4).stroke(WalletLook.foreground.opacity(enabled ? 1 : 0.3), lineWidth: 1))
        }
    }
    //@endif
    """##
}
