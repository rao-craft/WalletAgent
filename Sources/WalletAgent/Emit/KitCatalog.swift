//  WHAT: Every file the kit can write, in the order a reader meets them: what the views read first (the protocols,
//        the conversions, the look, the words, the launch, the shared pieces), then the building blocks, then the
//        sheets and the root.

import Foundation

enum KitCatalog {
    /// The name every type the kit declares starts with, which the call's `prefix` replaces.
    static let base = "Wallet"

    static let parts: [KitPart] = [
        KitPart("WalletProtocols", types: ["WalletRepresentable", "WalletGroupRepresentable", "WalletExchangeRepresentable",
                                           "WalletTransactionRepresentable", "WalletItem", "WalletGroupItem", "WalletExchangeItem",
                                           "WalletTransactionItem"], view: false),
        KitPart("WalletValue", view: false, Template.walletValue),
        KitPart("WalletLook", view: false),
        KitPart("WalletStrings", view: false),
        KitPart("WalletLaunch", view: false),
        KitPart("WalletSupport", types: ["WalletFormat", "WalletHaptic", "WalletIndex", "WalletCardStyle", "WalletDetailRow", "WalletOutlined"],
                view: false, Template.walletSupport),
        KitPart("WalletEyebrow", Template.walletEyebrow),
        KitPart("WalletCloseButton", types: ["WalletCloseButton", "WalletSheetBar"], Template.walletCloseButton),
        KitPart("WalletHeroView", Template.walletHeroView),
        KitPart("WalletWithdrawButton", flag: "withdraw", Template.walletWithdrawButton),
        KitPart("WalletTotalsView", Template.walletTotalsView),
        KitPart("WalletSection", Template.walletSection),
        KitPart("WalletGroupCard", Template.walletGroupCard),
        KitPart("WalletExchangeCard", Template.walletExchangeCard),
        KitPart("WalletExchangeRow", Template.walletExchangeRow),
        KitPart("WalletTransactionRow", Template.walletTransactionRow),
        KitPart("WalletExchangesSheet", Template.walletExchangesSheet),
        KitPart("WalletExchangeSheet", Template.walletExchangeSheet),
        KitPart("WalletWithdrawSheet", types: ["WalletWithdrawSheet", "WalletWithdrawal"], flag: "withdraw.sheet", Template.walletWithdrawSheet),
        KitPart("WalletView", Template.walletView),
        KitPart("WalletPreviews", types: ["WalletSample"], view: false, Template.walletPreviews),
    ]

    /// Every type any call can declare, for renaming.
    static var names: [String] { parts.flatMap(\.types) }

    static func part(_ name: String) -> KitPart? { parts.first { $0.name == name } }
}
