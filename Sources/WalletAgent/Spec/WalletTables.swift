//  WHAT: Everything a call can set by name: the look roles the views read, every word they say, every number, size,
//        symbol and motion they use, and the states the root view can open in. The one source of the schema's key
//        lists, of `Wallet.md`'s tables, of what a line may name, and of what the emitted enums hold.
//  PIN:  ONE TABLE EACH. A template reads a word as `WalletStrings.member` and a number as `{{key}}`; a test holds
//        every template to these tables, so a key named here is a key the views use, and the other way round.

import Foundation

enum WalletTables {
    // MARK: Look

    static let look: [LookRole] = [
        LookRole("title", .font, ".headline", "Sheet titles in the bar."),
        LookRole("heading", .font, ".title3", "The blocks' headings: the groups, the exchanges, the transactions."),
        LookRole("note", .font, ".callout", "A card's or a row's name, and the loading line."),
        LookRole("note2", .font, ".footnote", "Dates, document counts and a detail row's words."),
        LookRole("accent", .color, ".accentColor", "\"See All\" and the controls that act."),
        LookRole("foreground", .color, ".primary", "Words and amounts."),
        LookRole("secondaryForeground", .color, ".secondary", "Eyebrows, labels and the unit beside the balance."),
        LookRole("secondaryBackground", .color, """
            #if os(iOS)
            return Color(uiColor: .secondarySystemBackground)
            #else
            return Color(nsColor: .controlBackgroundColor)
            #endif
            """, "The small cards and the totals' cells, drawn at the card opacity."),
        LookRole("positive", .color, ".green", "The available line and a cashout's amount."),
        LookRole("gutter", .length, "20", "The page's side margin."),
    ]

    // MARK: Strings

    static let strings: [StringKey] = [
        StringKey("title", "Wallet", "The bar's title."),
        StringKey("amount", "%.2f cr", "How every amount reads: one number format and its unit, like `%.4f cr` or `$%.2f`."),
        StringKey("close", "Close", "The close button's accessibility label."),
        StringKey("balance.eyebrow", "BALANCE", "The eyebrow over the balance."),
        StringKey("balance.thousands", "K cr", "The unit beside a balance of a thousand or more, shown in thousands: `K` and the amount's unit."),
        StringKey("balance.millions", "M cr", "The unit beside a balance of a million or more, shown in millions."),
        StringKey("earnings.eyebrow", "EARNINGS", "The eyebrow over the earnings."),
        StringKey("available", "{amount} available", "The green line under the earnings: what can be cashed out."),
        StringKey("earned", "Earned", "The first total's label."),
        StringKey("spent", "Spent", "The second total's label."),
        StringKey("cashedOut", "Cashed Out", "The third total's label."),
        StringKey("groups.title", "Groups", "The groups' heading."),
        StringKey("groups.empty", "No group earnings yet", "What the groups' row says when no group has earned."),
        StringKey("group.documents", "{count} documents", "A group card's document count."),
        StringKey("group.documents.one", "{count} document", "A group card's count of one document."),
        StringKey("exchanges.title", "Exchanges", "The exchanges' heading."),
        StringKey("exchanges.seeAll", "See All", "The button that opens every exchange."),
        StringKey("exchanges.empty", "No exchanges yet", "What the exchanges' row says when there are none."),
        StringKey("exchange.title", "Exchange", "An exchange's name when its type maps no `title`; its sheet's title too."),
        StringKey("exchange.fee", "fee {amount}", "The fee under an exchange's cost."),
        StringKey("transactions.title", "Transactions", "The transactions' heading."),
        StringKey("transactions.empty", "No cashouts recorded", "What the transactions say when there are none."),
        StringKey("transaction.title", "Cashout", "A transaction's name when its type maps no `title`."),
        StringKey("transaction.amount", "+ {amount}", "A transaction's amount."),
        StringKey("loading", "Loading wallet…", "Under the spinner while the wallet loads."),
        StringKey("unavailable", "Wallet unavailable", "When the wallet could not be loaded."),
        StringKey("allExchanges.title", "All Exchanges", "The title of the sheet with every exchange."),
        StringKey("allExchanges.eyebrow", "TOTAL EXCHANGES", "The eyebrow over the count there."),
        StringKey("allExchanges.count", "{count} exchanges", "How many exchanges there are."),
        StringKey("allExchanges.count.one", "{count} exchange", "The count of one exchange."),
        StringKey("exchange.eyebrow", "COST", "The eyebrow over an exchange's cost, in its sheet."),
        StringKey("exchange.documents", "Documents", "The detail row of the documents it used."),
        StringKey("exchange.serviceFee", "Service Fee", "The detail row of its fee."),
        StringKey("exchange.total", "Total Cost", "The detail row of what it would have cost."),
        StringKey("exchange.savings", "Savings", "The detail row of what it saved."),
        StringKey("exchange.saved", "-{amount}", "How the savings read."),
        StringKey("withdraw", "Withdraw", "The withdraw button.", part: "withdraw"),
        StringKey("withdraw.soon", "Coming soon", "Under the withdraw button while withdrawals are not open.", part: "withdraw.soon"),
        StringKey("withdraw.title", "Withdraw", "The withdrawal sheet's title.", part: "withdraw.on"),
        StringKey("withdraw.bank", "Connect a Bank", "The withdrawal sheet's heading.", part: "withdraw.on"),
        StringKey("withdraw.privacy", "Your account details are encrypted\nand never stored on our servers.", "Under the heading.", part: "withdraw.on"),
        StringKey("withdraw.routing", "Routing Number", "The routing number's label.", part: "withdraw.on"),
        StringKey("withdraw.routing.placeholder", "9-digit routing number", "The routing number's placeholder.", part: "withdraw.on"),
        StringKey("withdraw.account", "Account Number", "The account number's label.", part: "withdraw.on"),
        StringKey("withdraw.account.placeholder", "Account number", "The account number's placeholder.", part: "withdraw.on"),
        StringKey("withdraw.kind", "Account Type", "The account type's label.", part: "withdraw.on"),
        StringKey("withdraw.checking", "Checking", "One account type.", part: "withdraw.on"),
        StringKey("withdraw.savings", "Savings", "The other account type.", part: "withdraw.on"),
        StringKey("withdraw.amount", "AMOUNT", "The eyebrow over the amount to withdraw.", part: "withdraw.on"),
        StringKey("withdraw.available", "Available: {amount}", "Under the amount: what can be withdrawn.", part: "withdraw.on"),
        StringKey("withdraw.max", "Max", "The button that fills in everything available.", part: "withdraw.on"),
        StringKey("withdraw.confirm", "Continue", "The button that sends the withdrawal.", part: "withdraw.on"),
        StringKey("withdraw.failed", "The withdrawal did not go through. Try again.", "When the app's withdrawal throws.", part: "withdraw.on"),
        StringKey("withdraw.done.title", "Withdrawal Initiated", "When the withdrawal is sent.", part: "withdraw.on"),
        StringKey("withdraw.done.note", "Funds typically arrive in 3–5 business days.", "Under it.", part: "withdraw.on"),
        StringKey("withdraw.done", "Done", "The button that closes the sheet.", part: "withdraw.on"),
    ]

    // MARK: Tuning

    static let tuning: [TuningKey] = [
        TuningKey("eyebrowTracking", .number, "2.5", "The eyebrows' tracking."),
        TuningKey("eyebrowSize", .number, "10", "The eyebrows' point size (system, medium)."),
        TuningKey("balanceSize", .number, "34", "The balance's size, and the big number atop each sheet."),
        TuningKey("unitSize", .number, "14", "The unit beside the balance."),
        TuningKey("earningsSize", .number, "22", "The earnings' size."),
        TuningKey("availableSize", .number, "12", "The available line's size."),
        TuningKey("availableSymbolSize", .number, "11", "The size of the symbol before the available line."),
        TuningKey("amountSize", .number, "15", "Amounts in the totals, the cards and the rows."),
        TuningKey("feeSize", .number, "11", "An exchange's fee, and the totals' labels."),
        TuningKey("seeAllSize", .number, "13", "\"See All\" and an exchange's date in its sheet."),
        TuningKey("groupCard", .size, "150x120", "A group card's width and height."),
        TuningKey("exchangeCard", .size, "145x130", "An exchange card's width and height."),
        TuningKey("exchangesShown", .integer, "24", "How many exchanges the row shows, newest first; See All shows them all."),
        TuningKey("cardOpacity", .number, "0.45", "How strongly a small card's background is drawn."),
        TuningKey("cardBorder", .number, "0.07", "The opacity of a small card's 1 pt border."),
        TuningKey("availableSymbol", .symbol, "arrow.up.circle.fill", "The symbol before the available line."),
        TuningKey("exchangesEmptySymbol", .symbol, "bolt.slash", "The symbol over the exchanges' empty line."),
        TuningKey("transactionsEmptySymbol", .symbol, "tray", "The symbol over the transactions' empty line."),
        TuningKey("unavailableSymbol", .symbol, "wallet.bifold", "The symbol over \"Wallet unavailable\"."),
        TuningKey("withdrawSymbol", .symbol, "arrow.down.to.line", "The symbol on the withdraw button.", part: "withdraw"),
        TuningKey("bankSymbol", .symbol, "building.columns", "The symbol atop the withdrawal sheet.", part: "withdraw.on"),
        TuningKey("design", .design, "serif", "The design of the amounts' and the cards' type."),
        TuningKey("material", .material, "regular", "The sheets' background material."),
        TuningKey("amountAnimation", .animation, ".easeOut(duration: 0.4)", "How the balance and the earnings change."),
    ]

    // MARK: Launch

    static let launch: [LaunchState] = [
        LaunchState("wallet", "The wallet, nothing over it."),
        LaunchState("exchanges", "Every exchange, the See All sheet open over the wallet."),
        LaunchState("exchange", "The newest exchange's sheet open over the wallet."),
        LaunchState("withdraw", "The withdrawal sheet open over the wallet; needs `withdraw: on` and the app's `withdraw:`.", part: "withdraw.on"),
    ]
}
