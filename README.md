# WalletAgent

Give an app a wallet without drawing it by hand. Say which of your types is the wallet, which are the groups that
earned, the exchanges that spent and the cashouts, and `wallet` writes the screen that shows them: the balance and the
earnings, three totals, a sideways row of group cards, a sideways row of exchange cards with See All, the cashouts, and
the sheets behind them. What it writes is plain SwiftUI that works in any app, with no Granite dependency in it.

## What you can ask

```
$wallet the credits wallet over SeerKit's Wallet, ModelEarning, CreditExchange and Cashout, amounts as %.4f cr
$wallet a points screen for the reading app: shelves earn, purchases spend, payouts cash out, prefixed Points
$wallet the wallet with a Withdraw button that says Coming soon, in the app's own fonts and accent
$wallet open on the See All sheet when the app is launched with -destination wallet.exchanges
```

Craft writes the call from your request, shows it on its agent map as `wallet-1`, and builds and tests what it writes
with the turn.

## What you get

- **The whole wallet.** The balance on one line beside its unit and the earnings with what can be cashed out, split
  by a thin rule; earned, spent and cashed out in three cells; the groups and the exchanges as small bordered cards in
  rows that scroll sideways; the cashouts, newest first; All Exchanges and one exchange's sheet with its fee, total and
  savings. A withdrawal sheet too, when you want one.
- **Your own types, shown as they are.** One line a type says which field is the balance, the name or the cost; the
  views read protocols, and your types are made to conform to them, without a change to the types themselves.
- **Your look and your words.** Map the fonts, colours and margin to your design's names. Every word is a key with a
  plain English default, and every size, symbol, material and motion is a key with a number.
- **Views ready to drop in.** They take values and closures, hold no global state and never route, so your app keeps
  its own navigation and presents the wallet as it likes. Every view has a `#Preview`, and every icon-only control is
  labelled for VoiceOver.
- **Screens reachable from a launch.** A `-destination` launch argument opens the wallet on its See All sheet or an
  exchange, already up, for UI tests and screenshots.

## How it works

- It reads each line and refuses one it cannot read with the reason and what the line can say, every bad line at
  once, and writes nothing.
- It writes from templates and asks no model, so the same call makes the same files every time.
- Every file is parsed with `swiftc -parse` before any lands, and they land together. A later call into the same
  folder writes the kit again and takes away what the new call no longer asks for.
- What it makes is built and tested with the turn.

## Works well with

`wallet` writes the wallet's screens; the other Rao Craft Agents fill in the rest. `network` and `models` write the
types it maps, `mocks` the data it shows before the server exists, `design` the fonts and colours its look maps to, and
`granite` the page that shows its `WalletView`, the service that loads the wallet, and the sheet it opens in.

## Get it

In Craft, install Wallet from the Agent Store, or run
`craft agents add https://github.com/rao-craft/WalletAgent.git`, then say `$wallet` in a request.

## Requirements

- A Mac on macOS 14 or later, with Xcode.
- The views target iOS 17 and macOS 14 and compile in Swift 5 and Swift 6 language modes. They are plain SwiftUI:
  no Granite, and no package to add.
- MIT licensed.

## For developers

Every field, line, word, number and launch state a call can give is in the [reference](Schema/Wallet.md), and how
`wallet` is tested is [TESTING.md](TESTING.md).
