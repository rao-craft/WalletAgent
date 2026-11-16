//  WHAT: The template of `WalletView.swift`, the root a page shows.

extension Template {
    static let walletView = ##"""
    import SwiftUI

    /// A wallet: the balance and the earnings, three totals, the groups that earned, the exchanges that spent (See
    /// All opens them all), and the cashouts, with the sheets behind them. A spinner shows while `wallet` is nil;
    /// `load` is called as it appears. It never routes: the app presents it and closes it.
    ///
    ///     WalletView(wallet: wallet.state.wallet, load: { try await wallet.load() })
    struct WalletView<Value: WalletRepresentable>: View {
        let wallet: Value?
        var load: (@MainActor () async throws -> Void)?
    //@if withdraw.on
        var withdraw: (@MainActor (WalletWithdrawal) async throws -> Void)?
    //@endif
        var close: (@MainActor () -> Void)?

        @State private var failed = false
        @State private var showsAll = false
        @State private var opened: WalletIndex?
    //@if withdraw.on
        @State private var withdrawing = false
    //@endif
        @State private var launched = false

        init(wallet: Value?, load: (@MainActor () async throws -> Void)? = nil,
    //@if withdraw.on
             withdraw: (@MainActor (WalletWithdrawal) async throws -> Void)? = nil,
    //@endif
             close: (@MainActor () -> Void)? = nil) {
            self.wallet = wallet
            self.load = load
    //@if withdraw.on
            self.withdraw = withdraw
    //@endif
            self.close = close
        }

        var body: some View {
            ZStack {
                if let wallet {
                    content(wallet)
                } else if failed {
                    unavailable
                } else {
                    loading
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .modifier(WalletSheetBar(title: WalletStrings.title, close: close))
            .presentationBackground(.{{material}})
            .task { await reload() }
            .task(id: wallet == nil) { await openLaunch() }
            .sheet(isPresented: $showsAll) {
                if let wallet {
                    WalletExchangesSheet(exchanges: exchanges(of: wallet))
                }
            }
            .sheet(item: $opened) { index in
                if let wallet, exchanges(of: wallet).indices.contains(index.id) {
                    WalletExchangeSheet(exchange: exchanges(of: wallet)[index.id])
                }
            }
    //@if withdraw.on
            .sheet(isPresented: $withdrawing) {
                if let wallet, let withdraw {
                    WalletWithdrawSheet(available: wallet.walletAvailable, withdraw: withdraw)
                }
            }
    //@endif
        }

        private func content(_ wallet: Value) -> some View {
            ScrollView {
                VStack(spacing: 0) {
                    WalletHeroView(balance: wallet.walletBalance, earnings: wallet.walletEarnings, available: wallet.walletAvailable)
                        .padding(.top, 24)
                        .padding(.bottom, 32)
                        .padding(.horizontal, WalletLook.gutter)
    //@if withdraw.on
                    if withdraw != nil {
                        WalletWithdrawButton(enabled: wallet.walletAvailable > 0) { withdrawing = true }
                            .padding(.horizontal, WalletLook.gutter + 8)
                            .padding(.bottom, 24)
                    }
    //@endif
    //@if withdraw.soon
                    WalletWithdrawButton()
                        .padding(.horizontal, WalletLook.gutter + 8)
                        .padding(.bottom, 24)
    //@endif
                    WalletTotalsView(earned: wallet.walletEarned, spent: wallet.walletSpent, cashedOut: wallet.walletCashedOut)
                        .padding(.horizontal, WalletLook.gutter)
                        .padding(.bottom, 32)
                    Divider()
                        .padding(.horizontal, WalletLook.gutter)
                    groups(wallet)
                    Divider()
                        .padding(.horizontal, WalletLook.gutter)
                    exchangesBlock(wallet)
                    Divider()
                        .padding(.horizontal, WalletLook.gutter)
                    transactions(wallet)
                        .padding(.bottom, 18)
                }
            }
        }

        private func groups(_ wallet: Value) -> some View {
            let cards = wallet.walletGroups.filter { $0.walletGroupEarnings > 0 }
            return WalletSection(title: WalletStrings.groupsTitle) {
                if cards.isEmpty {
                    Text(WalletStrings.groupsEmpty)
                        .font(WalletLook.note)
                        .foregroundStyle(WalletLook.secondaryForeground)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(cards.enumerated()), id: \.offset) { _, group in
                                WalletGroupCard(group: group)
                            }
                        }
                        .padding(.horizontal, WalletLook.gutter)
                        .padding(.vertical, 12)
                    }
                }
            }
        }

        private func exchangesBlock(_ wallet: Value) -> some View {
            let cards = exchanges(of: wallet)
            return WalletSection(title: WalletStrings.exchangesTitle, trailing: cards.isEmpty ? nil : WalletStrings.exchangesSeeAll,
                                 onTrailing: { showsAll = true }) {
                if cards.isEmpty {
                    empty(WalletStrings.exchangesEmpty, symbol: "{{exchangesEmptySymbol}}")
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(cards.prefix({{exchangesShown}}).enumerated()), id: \.offset) { index, exchange in
                                WalletExchangeCard(exchange: exchange) { opened = WalletIndex(id: index) }
                            }
                        }
                        .padding(.horizontal, WalletLook.gutter)
                        .padding(.vertical, 12)
                    }
                }
            }
        }

        private func transactions(_ wallet: Value) -> some View {
            let rows = WalletFormat.newestFirst(wallet.walletTransactions) { $0.walletTransactionDate }
            return WalletSection(title: WalletStrings.transactionsTitle) {
                if rows.isEmpty {
                    empty(WalletStrings.transactionsEmpty, symbol: "{{transactionsEmptySymbol}}")
                } else {
                    VStack(spacing: 0) {
                        ForEach(Array(rows.enumerated()), id: \.offset) { index, transaction in
                            WalletTransactionRow(transaction: transaction)
                            if index < rows.count - 1 {
                                Divider()
                                    .padding(.horizontal, WalletLook.gutter)
                            }
                        }
                    }
                }
            }
        }

        private func empty(_ text: String, symbol: String) -> some View {
            VStack(spacing: 12) {
                Image(systemName: symbol)
                    .font(.system(size: 22))
                    .foregroundStyle(.tertiary)
                Text(text)
                    .font(WalletLook.note)
                    .foregroundStyle(WalletLook.secondaryForeground)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
        }

        private var loading: some View {
            VStack(spacing: 16) {
                ProgressView()
                Text(WalletStrings.loading)
                    .font(WalletLook.note)
                    .foregroundStyle(WalletLook.secondaryForeground)
            }
        }

        private var unavailable: some View {
            VStack(spacing: 12) {
                Image(systemName: "{{unavailableSymbol}}")
                    .foregroundStyle(.tertiary)
                Text(WalletStrings.unavailable)
                    .font(WalletLook.note)
                    .foregroundStyle(WalletLook.secondaryForeground)
            }
        }

        /// The exchanges, newest first.
        private func exchanges(of wallet: Value) -> [Value.ExchangeValue] {
            WalletFormat.newestFirst(wallet.walletExchanges) { $0.walletExchangeDate }
        }

        private func reload() async {
            guard let load else { return }
            failed = false
            do {
                try await load()
            } catch {
                failed = true
            }
        }

        /// The sheet a `-destination` launch asks for, opened unanimated once the wallet is there and has settled.
        private func openLaunch() async {
            guard wallet != nil, !launched, let state = WalletLaunch.state else { return }
            launched = true
            try? await Task.sleep(for: .milliseconds(600))
            var transaction = SwiftUI.Transaction()
            transaction.disablesAnimations = true
            withTransaction(transaction) {
                switch state {
                case .wallet:
                    break
                case .exchanges:
                    showsAll = true
                case .exchange:
                    if let wallet, !wallet.walletExchanges.isEmpty { opened = WalletIndex(id: 0) }
    //@if withdraw.on
                case .withdraw:
                    if withdraw != nil { withdrawing = true }
    //@endif
                }
            }
        }
    }

    #Preview("Wallet") {
        NavigationStack {
            WalletView(wallet: WalletSample.wallet, close: {})
        }
    }

    #Preview("Loading") {
        NavigationStack {
            WalletView<WalletItem>(wallet: nil)
        }
    }
    """##
}
