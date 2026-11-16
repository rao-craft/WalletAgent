# craft-agent/1 · wallet

Writes a credits wallet as plain SwiftUI (the balance and earnings, three totals, the groups that earned, the exchanges that spent with See All, the cashouts and the sheets behind them), made to show the app's own types from one mapping line a type.

wallet's copy of Craft's agent standard (`craft-agent/1`, Craft's `Schema/Agent.md`), with the reference of every
line it reads. Everything above **Changes** describes the agent as it is; Changes is wallet's own log.

| File | What it holds |
| --- | --- |
| [`wallet.input.schema.json`](wallet.input.schema.json) | What it takes, as JSON Schema |
| [`wallet.answer.schema.json`](wallet.answer.schema.json) | What it answers: `granite-answer/1` with its own kinds |
| [`examples/seer.json`](examples/seer.json) | The call that writes Seer's wallet: its types, its words, its numbers |
| [`examples/seer.answer.json`](examples/seer.answer.json) | What that call answers |
| [`examples/reading-points.json`](examples/reading-points.json) | A call for another app: a reading app's points, with a withdrawal and a prefix |

## What it takes

| Field | Required | What it is |
| --- | --- | --- |
| `into` | no | the folder for the views, relative to the project; Components/Wallet when left out |
| `mappings` | no | one line a role (wallet, group, exchange, transaction): `wallet: Wallet balance=balance earned=earned spent=spent cashedOut=cashedOut groups=groups exchanges=exchanges transactions=cashouts`; a bare path is read off the value, anything else is Swift that may name `value` |
| `imports` | no | modules the conformances import, such as the package a mapped type is declared in |
| `look` | no | look roles mapped to the app's names, one a line: `title = Font.brandTitle`; roles title, heading, body, note, note2 (Font), accent, foreground, secondaryForeground, secondaryBackground, positive (Color), gutter (CGFloat); an unmapped role is the system's |
| `strings` | no | the words, one a line, `key = words` (quotes optional): `title = Wallet`, `amount = %.4f cr`, `groups.title = Model Groups`; every key and its default in Wallet.md |
| `tuning` | no | numbers, sizes, symbols and motion, one a line: `eyebrowTracking = 2.5`, `groupCard = 150x120`, `availableSymbol = arrow.up.circle.fill`, `amountAnimation = .easeOut(duration: 0.4)`; every key in Wallet.md |
| `launch` | no | the state the root opens in for a launch with `-destination <name>`, one a line: `wallet.exchanges = exchanges`; states wallet, exchanges, exchange, withdraw |
| `withdraw` | no | on (a Withdraw button, drawn when the page passes `withdraw:`, opening the withdrawal sheet; the default), soon (a faded button with "Coming soon"; a `withdraw` launch line still opens the sheet) or off (none) |
| `prefix` | no | what the kit's names start with instead of Wallet, when the app already has those names: `Credits` writes CreditsView |

`directory` is filled by Craft with the project folder. The person's request and the host's model are offered
beside the call, never in it.

## The lines

Every list field takes one line a thing. A line it cannot read is refused with the reason, every bad line at once, and nothing is written.

### `mappings`: `role: Type word=value …`

A role, a colon, the app's type, then `word=value` for each thing the views show, spaces or commas between. A value that is a bare path (`balance`, `stats.earned`, `owner?.name`) is read off the value; anything else is Swift that may name `value` (`amount=Double(value.cents) / 100`). Every value goes through `WalletValue`, so an amount may be a Double, a Float, a Decimal, a whole number or a String of digits, a count a whole number or a list that is counted, a date a Date, an ISO string or seconds. A word left out takes the default. A list (groups, exchanges, transactions) needs the line of its role for the type it holds; a role no line maps uses the kit's own value (`WalletItem`, `WalletGroupItem`, `WalletExchangeItem`, `WalletTransactionItem`).

**wallet** (a line may also start account, balance, credits, purse)

| Word | Requirement | Type | Left out | What it is | Also read as |
| --- | --- | --- | --- | --- | --- |
| `balance` | `walletBalance` | `Double` | `0` | What the wallet holds now. | credits, total, held |
| `earned` | `walletEarned` | `Double` | `0` | Everything it has earned. | totalEarned, totalEarnings |
| `spent` | `walletSpent` | `Double` | `0` | Everything it has spent. | totalSpent |
| `cashedOut` | `walletCashedOut` | `Double` | `0` | Everything it has cashed out. | cashed, cashout, withdrawn, paidOut, totalCashedOut |
| `earnings` | `walletEarnings` | `Double` | `walletEarned` | The earnings the head shows; what it earned when left out. | income |
| `available` | `walletAvailable` | `Double` | `walletEarned - walletCashedOut` | What can be cashed out; earned less cashed out when left out. | availableBalance, withdrawable |
| `groups` | `walletGroups` | `[GroupValue]` | `[]` | The groups that earned, one card each. | models, collections, earningsByGroup, sources |
| `exchanges` | `walletExchanges` | `[ExchangeValue]` | `[]` | What was spent, one exchange each. | spends, charges, usage |
| `transactions` | `walletTransactions` | `[TransactionValue]` | `[]` | What was cashed out, one transaction each. | cashouts, payouts, withdrawals, movements |

**group** (a line may also start model, collection, earning, source)

| Word | Requirement | Type | Left out | What it is | Also read as |
| --- | --- | --- | --- | --- | --- |
| `name` | `walletGroupName` | `String` | `""` | Its name, at the top of its card. | title, label |
| `documents` | `walletGroupDocuments` | `Int` | `0` | How many documents it holds: a count, or a list that is counted. | count, items, docs, documentCount |
| `earnings` | `walletGroupEarnings` | `Double` | `0` | What it earned, at the bottom of its card. | earned, amount, credits |

**exchange** (a line may also start spend, charge, usage, inference)

| Word | Requirement | Type | Left out | What it is | Also read as |
| --- | --- | --- | --- | --- | --- |
| `title` | `walletExchangeTitle` | `String?` | `nil` | What it was for; the strings' `exchange.title` when left out. | name, kind, label |
| `date` | `walletExchangeDate` | `Date?` | `nil` | When it was made. | createdAt, timestamp, at, day |
| `cost` | `walletExchangeCost` | `Double` | `0` | What it cost, net. | netCost, amount, spent, price |
| `fee` | `walletExchangeFee` | `Double` | `0` | The service fee within it. | serviceFee, serviceCharge, charge |
| `documents` | `walletExchangeDocuments` | `Int` | `0` | How many documents it used: a count, or a list that is counted. | documentIds, docs, documentCount |
| `savings` | `walletExchangeSavings` | `Double` | `0` | What it saved. | saved, saving, discount |
| `total` | `walletExchangeTotal` | `Double` | `walletExchangeCost + walletExchangeSavings` | What it would have cost; cost and savings together when left out. | totalCost, gross |

**transaction** (a line may also start cashout, payout, withdrawal, movement)

| Word | Requirement | Type | Left out | What it is | Also read as |
| --- | --- | --- | --- | --- | --- |
| `title` | `walletTransactionTitle` | `String?` | `nil` | What it was; the strings' `transaction.title` when left out. | name, kind, label |
| `date` | `walletTransactionDate` | `Date?` | `nil` | When it was made. | createdAt, timestamp, at, day |
| `amount` | `walletTransactionAmount` | `Double` | `0` | How much it moved. | value, credits, sum |

### `imports`

Module names, one an item: what the conformances import, such as the package a mapped type is declared in (`SeerKit`). A type found in a local package of the project is imported without being named.

### `look`: `role = expression`

Maps a look role to the app's own name for it. A font role takes a `Font` expression, a colour role a `Color`, the gutter a number or a `CGFloat` expression. An unmapped role is the system's value below, so the views build in any app.

| Role | Type | When unmapped | What it styles |
| --- | --- | --- | --- |
| `title` | Font | `.headline` | Sheet titles in the bar. |
| `heading` | Font | `.title3` | The blocks' headings: the groups, the exchanges, the transactions. |
| `body` | Font | `.title2` | The withdrawal's headings: "Connect a Bank" and "Withdrawal Initiated". |
| `note` | Font | `.callout` | A card's or a row's name, and the loading line. |
| `note2` | Font | `.footnote` | Dates, document counts and a detail row's words. |
| `accent` | Color | `.accentColor` | "See All" and the controls that act. |
| `foreground` | Color | `.primary` | Words and amounts. |
| `secondaryForeground` | Color | `.secondary` | Eyebrows, labels and the unit beside the balance. |
| `secondaryBackground` | Color | secondarySystemBackground (iOS), controlBackgroundColor (macOS) | The small cards and the totals' cells, drawn at the card opacity. |
| `positive` | Color | `.green` | The available line and a cashout's amount. |
| `gutter` | CGFloat | `20` | The page's side margin. |

### `strings`: `key = words`

Sets any word the views say. Quotes are optional; a quoted value reads `\n` and `\"`. `{amount}` stands for an amount as `amount` writes it and `{count}` for a whole number; a line must say the same `{…}` as the default. `amount` holds exactly one number format (`%.4f`, `%.0f`) with its unit before or after it; the balance shows its number and its unit apart, cut from it. A key ending `.one` is what its key says of one. A key marked with a part is written only with that part; the withdrawal sheet is written with `withdraw: on`, and with `soon` for a `withdraw` launch line.

| Key | Default | What it is | Written with |
| --- | --- | --- | --- |
| `title` | Wallet | The bar's title. | always |
| `amount` | %.2f cr | How every amount reads: one number format and its unit, like `%.4f cr` or `$%.2f`. | always |
| `close` | Close | The close button's accessibility label. | always |
| `balance.eyebrow` | BALANCE | The eyebrow over the balance. | always |
| `balance.thousands` | K cr | The unit beside a balance of a thousand or more, shown in thousands: `K` and the amount's unit. | always |
| `balance.millions` | M cr | The unit beside a balance of a million or more, shown in millions. | always |
| `earnings.eyebrow` | EARNINGS | The eyebrow over the earnings. | always |
| `available` | {amount} available | The green line under the earnings: what can be cashed out. | always |
| `earned` | Earned | The first total's label. | always |
| `spent` | Spent | The second total's label. | always |
| `cashedOut` | Cashed Out | The third total's label. | always |
| `groups.title` | Groups | The groups' heading. | always |
| `groups.empty` | No group earnings yet | What the groups' row says when no group has earned. | always |
| `group.documents` | {count} documents | A group card's document count. | always |
| `group.documents.one` | {count} document | A group card's count of one document. | always |
| `exchanges.title` | Exchanges | The exchanges' heading. | always |
| `exchanges.seeAll` | See All | The button that opens every exchange. | always |
| `exchanges.empty` | No exchanges yet | What the exchanges' row says when there are none. | always |
| `exchange.title` | Exchange | An exchange's name when its type maps no `title`; its sheet's title too. | always |
| `exchange.fee` | fee {amount} | The fee under an exchange's cost. | always |
| `transactions.title` | Transactions | The transactions' heading. | always |
| `transactions.empty` | No cashouts recorded | What the transactions say when there are none. | always |
| `transaction.title` | Cashout | A transaction's name when its type maps no `title`. | always |
| `transaction.amount` | + {amount} | A transaction's amount. | always |
| `loading` | Loading wallet… | Under the spinner while the wallet loads. | always |
| `unavailable` | Wallet unavailable | When the wallet could not be loaded. | always |
| `allExchanges.title` | All Exchanges | The title of the sheet with every exchange. | always |
| `allExchanges.eyebrow` | TOTAL EXCHANGES | The eyebrow over the count there. | always |
| `allExchanges.count` | {count} exchanges | How many exchanges there are. | always |
| `allExchanges.count.one` | {count} exchange | The count of one exchange. | always |
| `exchange.eyebrow` | COST | The eyebrow over an exchange's cost, in its sheet. | always |
| `exchange.documents` | Documents | The detail row of the documents it used. | always |
| `exchange.serviceFee` | Service Fee | The detail row of its fee. | always |
| `exchange.total` | Total Cost | The detail row of what it would have cost. | always |
| `exchange.savings` | Savings | The detail row of what it saved. | always |
| `exchange.saved` | -{amount} | How the savings read. | always |
| `withdraw` | Withdraw | The withdraw button. | `withdraw: on` or `soon` |
| `withdraw.soon` | Coming soon | Under the withdraw button while withdrawals are not open. | `withdraw: soon` |
| `withdraw.bank.title` | Connect Bank | The withdrawal's first step's title: the bank account. | the withdrawal sheet |
| `withdraw.bank` | Connect a Bank | The first step's heading. | the withdrawal sheet |
| `withdraw.privacy` | Your account details are encrypted\nand never stored on our servers. | Under the heading. | the withdrawal sheet |
| `withdraw.routing` | Routing Number | The routing number's label. | the withdrawal sheet |
| `withdraw.routing.placeholder` | 9-digit routing number | The routing number's placeholder. | the withdrawal sheet |
| `withdraw.account` | Account Number | The account number's label. | the withdrawal sheet |
| `withdraw.account.placeholder` | Account number | The account number's placeholder. | the withdrawal sheet |
| `withdraw.kind` | Account Type | The account type's label. | the withdrawal sheet |
| `withdraw.checking` | Checking | One account type, and how the later steps name it. | the withdrawal sheet |
| `withdraw.savings` | Savings | The other account type. | the withdrawal sheet |
| `withdraw.continue` | Continue | The button that goes on from the account and from the amount. | the withdrawal sheet |
| `withdraw.back` | Back | The back chevron's accessibility label, on the amount and the review. | the withdrawal sheet |
| `withdraw.title` | Withdraw | The second step's title: the amount. | the withdrawal sheet |
| `withdraw.amount` | AMOUNT | The eyebrow over the amount to withdraw. | the withdrawal sheet |
| `withdraw.available` | Available: {amount} | Under the amount: what can be withdrawn. | the withdrawal sheet |
| `withdraw.quarter` | 25% | The quick amount of a quarter of what is available. | the withdrawal sheet |
| `withdraw.half` | 50% | The quick amount of half of it. | the withdrawal sheet |
| `withdraw.max` | Max | The quick amount of all of it. | the withdrawal sheet |
| `withdraw.review.title` | Review | The third step's title. | the withdrawal sheet |
| `withdraw.review.amount` | WITHDRAWAL AMOUNT | The eyebrow over the amount in the review. | the withdrawal sheet |
| `withdraw.review.to` | To | The review's row of the account. | the withdrawal sheet |
| `withdraw.review.routing` | Routing | The review's row of the routing number. | the withdrawal sheet |
| `withdraw.review.arrival` | Est. Arrival | The review's row of when the money arrives. | the withdrawal sheet |
| `withdraw.review.arrives` | 3–5 business days | What that row says. | the withdrawal sheet |
| `withdraw.confirm` | Confirm Withdrawal | The button that sends the withdrawal; faded with `withdraw: soon`, which sends nothing. | the withdrawal sheet |
| `withdraw.failed` | The withdrawal did not go through. Try again. | When the app's withdrawal throws. | `withdraw: on` |
| `withdraw.done.title` | Initiated | The last step's title. | the withdrawal sheet |
| `withdraw.done.heading` | Withdrawal Initiated | The last step's heading. | the withdrawal sheet |
| `withdraw.done.note` | Funds typically arrive in 3–5 business days. | Under it. | the withdrawal sheet |
| `withdraw.done` | Done | The button that closes the sheet. | the withdrawal sheet |

### `tuning`: `key = value`

Sets any number, size, symbol or motion the views use. A number is a decimal (`2.5`), a whole number an integer, a size `width x height` (`150x120`), a symbol an SF Symbol's name, a design one of default, serif, rounded or monospaced, a material one of ultraThin, thin, regular, thick or ultraThick, and a motion an animation as SwiftUI writes it (`.easeOut(duration: 0.4)`, `.spring(response: 0.4, dampingFraction: 0.8)`). Each is written into the views where a person would write the number.

| Key | Kind | Default | What it sets |
| --- | --- | --- | --- |
| `eyebrowTracking` | number | `2.5` | The eyebrows' tracking. |
| `eyebrowSize` | number | `10` | The eyebrows' point size (system, medium). |
| `balanceSize` | number | `34` | The balance's size, and the big number atop each sheet. |
| `unitSize` | number | `14` | The unit beside the balance. |
| `earningsSize` | number | `22` | The earnings' size. |
| `availableSize` | number | `12` | The available line's size. |
| `availableSymbolSize` | number | `11` | The size of the symbol before the available line. |
| `amountSize` | number | `15` | Amounts in the totals, the cards and the rows. |
| `feeSize` | number | `11` | An exchange's fee, and the totals' labels. |
| `seeAllSize` | number | `13` | "See All" and an exchange's date in its sheet. |
| `groupCard` | size | `150x120` | A group card's width and height. |
| `exchangeCard` | size | `145x130` | An exchange card's width and height. |
| `exchangesShown` | integer | `24` | How many exchanges the row shows, newest first; See All shows them all. |
| `cardOpacity` | number | `0.45` | How strongly a small card's background is drawn. |
| `cardBorder` | number | `0.07` | The opacity of a small card's 1 pt border. |
| `availableSymbol` | symbol | `arrow.up.circle.fill` | The symbol before the available line. |
| `exchangesEmptySymbol` | symbol | `bolt.slash` | The symbol over the exchanges' empty line. |
| `transactionsEmptySymbol` | symbol | `tray` | The symbol over the transactions' empty line. |
| `unavailableSymbol` | symbol | `wallet.bifold` | The symbol over "Wallet unavailable". |
| `withdrawSymbol` | symbol | `arrow.down.to.line` | The symbol on the withdraw button. Written with a withdraw button. |
| `bankSymbol` | symbol | `building.columns` | The symbol atop the withdrawal's first step, and in its account badge. Written with the withdrawal sheet. |
| `design` | design | `serif` | The design of the amounts' and the cards' type. |
| `material` | material | `regular` | The sheets' background material. |
| `amountAnimation` | animation | `.easeOut(duration: 0.4)` | How the balance and the earnings change. |
| `withdrawAnimation` | animation | `.easeInOut(duration: 0.26)` | How the withdrawal's steps change. Written with the withdrawal sheet. |

### `launch`: `destination = state`

Maps a `-destination <name>` launch argument (read as `UserDefaults.standard.string(forKey: "destination")`) to the state the root view opens in: within 2 s of the wallet being there, its own sheets for the state are already up, put up without animation. The app's navigation opens the wallet itself for the destination (an alias such as `wallet.exchanges -> wallet`); with no line, every launch is a plain one.

| State | What is on screen |
| --- | --- |
| `wallet` | The wallet, nothing over it. |
| `exchanges` | Every exchange, the See All sheet open over the wallet. |
| `exchange` | The newest exchange's sheet open over the wallet. |
| `withdraw` | The withdrawal sheet open over the wallet, on its first step: with `withdraw: on` when the page passes `withdraw:`, or with `soon`, its button still faded. |

## What it writes

Into `into` (`Components/Wallet` when left out), every file parsed with `swiftc -parse` before any lands:

| File | What it is |
| --- | --- |
| `WalletProtocols.swift` | The four protocols the views read, a default for every requirement, and the kit's own value types |
| `WalletValue.swift` | The conversions every mapped value goes through |
| `WalletLook.swift`, `WalletStrings.swift`, `WalletLaunch.swift` | The look roles, every word and the launch state, from the call |
| `WalletSupport.swift` | How amounts and dates read, the taps, the looks the views repeat: the small card, a detail row, the outlined button |
| `WalletView.swift` | The root a page shows: the head, the totals, the groups, the exchanges, the cashouts, and its sheets |
| `WalletHeroView.swift`, `WalletTotalsView.swift`, `WalletSection.swift` | The head (balance and earnings), the three totals, a block with its heading |
| `WalletGroupCard.swift`, `WalletExchangeCard.swift`, `WalletExchangeRow.swift`, `WalletTransactionRow.swift` | The cards and rows |
| `WalletExchangesSheet.swift`, `WalletExchangeSheet.swift` | Every exchange (See All), and one exchange |
| `WalletEyebrow.swift`, `WalletCloseButton.swift` | The tracked eyebrow, the close mark and the bar every screen wears |
| `WalletWithdrawButton.swift` | With `withdraw: on` or `soon` (faded, with "Coming soon" under it) |
| `WalletWithdrawSheet.swift` | With `withdraw: on`, and with `soon` for a `withdraw` launch line: the bank account, the amount, the review, done; with `soon` its Confirm stays faded and nothing is sent |
| `WalletPreviews.swift` | The sample wallet every `#Preview` draws |
| `Conformances/<Type>+<Role>.swift` | One extension a mapping line |

A later call into the same folder writes the kit again; a file the new call does not write (a withdrawal it turned
off, a conformance it no longer maps) is removed.

The root, as the answer's `roots` gives it:

```swift
WalletView(wallet: Wallet?, load: (() async throws -> Void)? = nil, close: (() -> Void)? = nil)
// with `withdraw: on`:
WalletView(wallet: Wallet?, load: (() async throws -> Void)? = nil, withdraw: ((WalletWithdrawal) async throws -> Void)? = nil, close: (() -> Void)? = nil)
```

`wallet` nil shows a spinner over `loading`; `load` is called as the view appears, and a throw shows `unavailable`.
`close` draws the close mark trailing in the bar; leave it out when the app's navigation draws its own. The root wears
its own bar (the title inline, in `title`) and needs a navigation stack around it, which a sheet's host gives it. The
views never route: the app presents the wallet and closes it, and the kit presents only its own sheets.

## What it makes

| Kind | What | Into | Never |
| --- | --- | --- | --- |
| `view` | a credits wallet as reusable SwiftUI views (WalletView, the root a page shows, and its hero, totals, cards, rows and sheets); a page shows it with WalletView(wallet:load:) | `Components/Wallet/*` | routes; never a page, a service, a client or a model type |
| `conformance` | the app's own types made the wallet's: one extension a mapping line | `Components/Wallet/Conformances/*` | a change to the app's types themselves |

## What it answers

A `granite-answer/1` answer (Granite's `Schema/GraniteAgent.md` §4.2): `paths`, `made` against `expected` by kind and
name, `problems` for what it could only do in part, and its own keys beside them: `views` (the root first),
`conformances`, `roots` (the root's initializer, for the page body that calls it) and `notes` (what the app still has
to do).

## How it refuses

With an `AgentRefusal` of kind `call`: every reason at once, each naming the field, the line and what it accepts, and
nothing written. A line it cannot read, a key it does not know, a value of the wrong kind, a role mapped twice, a list
mapped with no line for its role, a field the app's type does not have, a launch state its part is not written for.

## Changes

Newest first.

### 2026-11-15 · a group's name at its look's size

A group card's name no longer shrinks to fit. The card is 120 high, and its lines want about 87 of the 72 inside its
padding; the name's scale factor of 0.7, which the original does not have, drew it 30% small and lifted the lines
under it 3 points. The name now keeps `note`'s size, as the original's does, and the lines spread into the padding.
Seer's `note = Font.brandNote` (serif 18 light, the original's `Text.note`) stays as it is.

### 2026-11-15 · the withdrawal as the original has it

From the first reading of the Seer call on the iPhone beside the original. `withdraw: soon` takes a `withdraw` launch
line: the sheet is written for it and opened by it, and the button stays faded with "Coming soon" under it. The sheet
is the original's four steps (Connect Bank, Withdraw, Review, Initiated), each sliding over the last, with the
original's fields, account type, quick amounts, review card and outlined buttons; with `soon` its Confirm stays faded
and nothing is sent. Its headings read a new look role, `body`. The balance wraps as the original's does, its unit on
its last line, instead of shrinking onto one. The outlined button and a detail row are one template each, shared by
every screen that draws them. Seer's call is now `withdraw: soon` with `wallet.withdraw = withdraw`.

### 2026-11-15 · first version

The wallet of Seer's original, mirrored subview by subview: the head in two columns split by a rule, the three
totals, the sideways rows of group and exchange cards, the cashouts, All Exchanges and one exchange's sheet, each with
the original's type, colour, material, spacing and motion, every number a tuning key and every word a string key.
Measured: the Seer call builds for the iPhone simulator in Swift 6 and Swift 5 (`WALLET_BUILD=1`), and every `code`
item of the scorecard's wallet area matches its output but B-wallet-11, the mock wallet's numbers, which are `$mocks`'.
