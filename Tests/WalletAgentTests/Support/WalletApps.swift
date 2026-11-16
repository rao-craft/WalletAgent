import Foundation

/// The apps the gated build writes the kit into: Seer (its design names stood in, its page written as the prompt
/// gives it), a reading app with its own types and a prefix, and the least call, plus the check each one runs.
enum WalletApps {
    /// The page body the prompt gives for `wallet`, when the app's navigation hosts the sheet without a close of its
    /// own: the kit draws the trailing close mark.
    static let seerBody = "WalletView(wallet: wallet.state.wallet, load: { try await wallet.load() }, close: { layout.closeSheet() })"

    /// The page body when the navigation draws its own close.
    static let seerPlainBody = "WalletView(wallet: wallet.state.wallet, load: { try await wallet.load() })"

    /// DesignAgent's names, as Seer's call maps them: the fonts, the accent and the layers.
    static let seerDesign = """
    import SwiftUI

    extension Font {
        static var brandTitle: Font { .system(size: 24, weight: .regular, design: .serif) }
        static var brandBody: Font { .system(size: 20, weight: .regular, design: .serif) }
        static var brandBody2: Font { .system(size: 18, weight: .regular, design: .serif) }
        static var brandNote: Font { .system(size: 18, weight: .light, design: .serif) }
        static var brandNote2: Font { .system(size: 16, weight: .light, design: .serif) }
    }

    extension Color {
        static var accent: Color { Color(red: 0.63, green: 0.49, blue: 0.31) }
    }

    extension CGFloat {
        static var layer1: CGFloat { 4 }
        static var layer2: CGFloat { 8 }
        static var layer3: CGFloat { 12 }
        static var layer4: CGFloat { 16 }
        static var layer5: CGFloat { 24 }
        static var layer6: CGFloat { 32 }
        static var layer7: CGFloat { 42 }
    }
    """

    /// The page `$granite` writes, its relays stood in by plain classes of the same shape: `wallet.state.wallet`,
    /// `try await wallet.load()`, `layout.closeSheet()`.
    static let seerPage = """
    import SwiftUI
    import SeerKit

    @MainActor
    final class WalletService {
        struct State {
            var wallet: Wallet?
        }

        var state = State()

        func load() async throws {
            state.wallet = WalletSamples.wallet
        }
    }

    @MainActor
    final class LayoutService {
        func closeSheet() {}
    }

    struct WalletPage: View {
        let wallet: WalletService
        let layout: LayoutService

        var body: some View {
            \(seerBody)
        }
    }

    struct WalletPlainPage: View {
        let wallet: WalletService

        var body: some View {
            \(seerPlainBody)
        }
    }
    """

    /// Seer's mock wallet, in SeerKit's types.
    static let seerSamples = """
    import Foundation
    import SeerKit

    enum WalletSamples {
        static var wallet: Wallet {
            let day: TimeInterval = 86_400
            let start = Date(timeIntervalSince1970: 1_794_528_000)
            let exchanges: [CreditExchange] = (0..<9).map { index in
                let date: Date = start.addingTimeInterval(-Double(index) * day)
                let cost: Double = 0.12 + Double(index % 4) * 0.03
                let fee: Double = index % 3 == 0 ? 0 : 0.02
                return CreditExchange(id: "x\\(index)", date: date, cost: cost, fee: fee, documents: 3, savings: 0.04)
            }
            return Wallet(balance: 6.62, earned: 42.37, spent: 21.5, cashedOut: 12,
                          groups: [ModelEarning(name: "Space", documents: 10, earnings: 18.42),
                                   ModelEarning(name: "Cooking", documents: 1, earnings: 9.75),
                                   ModelEarning(name: "Unearned", documents: 2, earnings: 0)],
                          exchanges: exchanges,
                          cashouts: [Cashout(id: "c1", date: start.addingTimeInterval(-20 * day), amount: 8),
                                     Cashout(id: "c2", date: start.addingTimeInterval(-5 * day), amount: 4)])
        }
    }
    """

    /// What Seer's targets run: the conversions and the words read back, the launch read, and every view drawn
    /// offscreen in light and dark.
    static let seerCheck = #"""
    import SwiftUI
    import SeerKit

    public enum __APP__Check {
        @MainActor
        public static func run() -> (drawn: [String], failed: [String]) {
            var drawn: [String] = [], failed: [String] = []
            func expect(_ name: String, _ holds: Bool) { if !holds { failed.append(name) } }
            func draw<Content: View>(_ name: String, height: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
                for scheme in [ColorScheme.light, .dark] {
                    let view = content()
                        .frame(width: 402, height: height)
                        .fixedSize(horizontal: false, vertical: height == nil)
                        .environment(\.colorScheme, scheme)
                    if ImageRenderer(content: view).cgImage == nil { failed.append(name) } else { drawn.append(name) }
                }
            }

            let wallet = WalletSamples.wallet
            expect("balance", wallet.walletBalance == 6.62)
            expect("earnings", wallet.walletEarnings == 42.37)
            expect("available", abs(wallet.walletAvailable - 30.37) < 0.000_1)
            expect("groups", wallet.walletGroups.count == 3 && wallet.walletGroups[0].walletGroupDocuments == 10)
            expect("exchanges", wallet.walletExchanges.count == 9 && wallet.walletExchanges[1].walletExchangeFee == 0.02)
            expect("exchange title", wallet.walletExchanges[0].walletExchangeTitle == nil)
            expect("exchange total", abs(wallet.walletExchanges[0].walletExchangeTotal - 0.16) < 0.000_1)
            expect("transactions", wallet.walletTransactions.count == 2)
            expect("amount", WalletFormat.amount(42.37) == "42.3700 cr")
            expect("available words", WalletStrings.available(WalletFormat.amount(30.37)) == "30.3700 cr available")
            expect("documents", WalletStrings.groupDocuments(1) == "1 document" && WalletStrings.groupDocuments(10) == "10 documents")
            expect("count", WalletStrings.allExchangesCount(9) == "9 exchanges" && WalletStrings.allExchangesCount(1) == "1 exchange")
            let small = WalletFormat.balance(6.62), thousands = WalletFormat.balance(12_500), millions = WalletFormat.balance(2_500_000)
            expect("balance parts", small.number == "6.6200" && small.unit == "cr")
            expect("thousands", thousands.number == "12.50" && thousands.unit == "K cr")
            expect("millions", millions.number == "2.50" && millions.unit == "M cr")
            expect("newest first", WalletFormat.newestFirst(wallet.walletTransactions) { $0.walletTransactionDate }.first?.walletTransactionAmount == 4)
            UserDefaults.standard.register(defaults: ["destination": "wallet.exchanges"])
            expect("launch", WalletLaunch.state == .exchanges)
            UserDefaults.standard.register(defaults: ["destination": "models"])
            expect("plain launch", WalletLaunch.state == nil)

            draw("hero") { WalletHeroView(balance: wallet.walletBalance, earnings: wallet.walletEarnings, available: wallet.walletAvailable) }
            draw("hero, thousands") { WalletHeroView(balance: 12_500, earnings: 0, available: 0) }
            draw("totals") { WalletTotalsView(earned: wallet.walletEarned, spent: wallet.walletSpent, cashedOut: wallet.walletCashedOut) }
            draw("group card") { WalletGroupCard(group: wallet.walletGroups[0]) }
            draw("exchange card") { WalletExchangeCard(exchange: wallet.walletExchanges[0], open: {}) }
            draw("exchange row") { WalletExchangeRow(exchange: wallet.walletExchanges[0]) }
            draw("transaction row") { WalletTransactionRow(transaction: wallet.walletTransactions[0]) }
            draw("section") { WalletSection(title: WalletStrings.exchangesTitle, trailing: WalletStrings.exchangesSeeAll, onTrailing: {}) { Text("x") } }
            draw("eyebrow") { WalletEyebrow(text: WalletStrings.balanceEyebrow) }
            draw("wallet", height: 874) { NavigationStack { WalletView(wallet: wallet, close: {}) } }
            draw("loading", height: 874) { NavigationStack { WalletView<Wallet>(wallet: nil) } }
            draw("all exchanges", height: 874) { WalletExchangesSheet(exchanges: wallet.walletExchanges) }
            draw("exchange", height: 874) { WalletExchangeSheet(exchange: wallet.walletExchanges[1]) }
            draw("exchange, no fee", height: 874) { WalletExchangeSheet(exchange: wallet.walletExchanges[0]) }
            draw("page", height: 874) { NavigationStack { WalletPage(wallet: WalletService(), layout: LayoutService()) } }
            draw("plain page", height: 874) { NavigationStack { WalletPlainPage(wallet: WalletService()) } }
            return (drawn, failed)
        }
    }
    """#

    /// What the reading app runs: its own types read through the conformances, its words, its launch, and every
    /// view of its prefixed kit drawn, the withdrawal among them.
    static let pointsCheck = #"""
    import SwiftUI

    public enum PointsCheck {
        @MainActor
        public static func run() -> (drawn: [String], failed: [String]) {
            var drawn: [String] = [], failed: [String] = []
            func expect(_ name: String, _ holds: Bool) { if !holds { failed.append(name) } }
            func draw<Content: View>(_ name: String, height: CGFloat? = nil, @ViewBuilder _ content: () -> Content) {
                for scheme in [ColorScheme.light, .dark] {
                    let view = content()
                        .frame(width: 402, height: height)
                        .fixedSize(horizontal: false, vertical: height == nil)
                        .environment(\.colorScheme, scheme)
                    if ImageRenderer(content: view).cgImage == nil { failed.append(name) } else { drawn.append(name) }
                }
            }

            let account = Account(points: 1_250, lifetimePoints: 3_000, spentPoints: 900, redeemed: 500,
                                  shelves: [Shelf(title: "Novels", books: ["Dune", "Emma", "Ulysses"], points: 400)],
                                  purchases: [Purchase(bookTitle: "Dune", boughtAt: "2026-11-01T10:00:00Z", price: Decimal(string: "4.99")!),
                                              Purchase(bookTitle: "Emma", boughtAt: "not a date", price: 2)],
                                  payouts: [Payout(paidAt: Date(timeIntervalSince1970: 1_790_000_000), cents: 1_250), Payout(paidAt: nil, cents: 99)])
            expect("balance", account.walletBalance == 1_250)
            expect("available", account.walletAvailable == 2_500)
            expect("shelf", account.walletGroups[0].walletGroupDocuments == 3 && account.walletGroups[0].walletGroupEarnings == 400)
            expect("purchase", account.walletExchanges[0].walletExchangeTitle == "Dune" && account.walletExchanges[0].walletExchangeDate != nil)
            expect("purchase price", abs(account.walletExchanges[0].walletExchangeCost - 4.99) < 0.000_1)
            expect("undated purchase", account.walletExchanges[1].walletExchangeDate == nil)
            expect("payout", account.walletTransactions[0].walletTransactionAmount == 12.5)
            expect("amount", PointsFormat.amount(1_250) == "1250 pts")
            let thousands = PointsFormat.balance(1_250)
            expect("thousands", thousands.number == "1.25" && thousands.unit == "K pts")
            UserDefaults.standard.register(defaults: ["destination": "points.redeem"])
            expect("launch", PointsLaunch.state == .withdraw)
            UserDefaults.standard.register(defaults: ["destination": "points"])
            expect("launch wallet", PointsLaunch.state == .wallet)

            draw("hero") { PointsHeroView(balance: account.walletBalance, earnings: account.walletEarnings, available: account.walletAvailable) }
            draw("withdraw button") { PointsWithdrawButton(enabled: true, action: {}) }
            draw("group card") { PointsGroupCard(group: account.walletGroups[0]) }
            draw("exchange card") { PointsExchangeCard(exchange: account.walletExchanges[1], open: {}) }
            draw("transaction row") { PointsTransactionRow(transaction: account.walletTransactions[1]) }
            draw("wallet", height: 874) { NavigationStack { PointsView(wallet: account, withdraw: { _ in }, close: {}) } }
            draw("withdrawal", height: 874) { PointsWithdrawSheet(available: account.walletAvailable, withdraw: { _ in }) }
            draw("all exchanges", height: 874) { PointsExchangesSheet(exchanges: account.walletExchanges) }
            return (drawn, failed)
        }
    }
    """#

    /// What the least call runs: no type of the app's, the kit's own values, the faded button.
    static let soonCheck = #"""
    import SwiftUI

    public enum SoonCheck {
        @MainActor
        public static func run() -> (drawn: [String], failed: [String]) {
            var drawn: [String] = [], failed: [String] = []
            func draw<Content: View>(_ name: String, @ViewBuilder _ content: () -> Content) {
                let view = content().frame(width: 402, height: 874)
                if ImageRenderer(content: view).cgImage == nil { failed.append(name) } else { drawn.append(name) }
            }
            if WalletLaunch.state != nil { failed.append("launch") }
            let wallet = WalletItem(balance: 3, earned: 5, spent: 1, cashedOut: 1,
                                    groups: [WalletGroupItem(name: "A", documents: 2, earnings: 1)],
                                    exchanges: [WalletExchangeItem(date: Date(), cost: 0.5, fee: 0, documents: 1, savings: 0)],
                                    transactions: [])
            draw("wallet") { NavigationStack { WalletView(wallet: wallet) } }
            draw("button") { WalletWithdrawButton() }
            return (drawn, failed)
        }
    }
    """#
}
