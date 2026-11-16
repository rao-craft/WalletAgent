//  WHAT: The template of `WalletSupport.swift`: how amounts and dates read, the light tap, the index a sheet opens
//        by, and the small card's style.

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
    """##
}
