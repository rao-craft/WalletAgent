# Testing WalletAgent

How `wallet` is tested: its own suite, and its gated build of real output.

## The suite

```
swift test                                            # the record, the schema, the lines, the templates, the files, a call through the roster
WALLET_BUILD=1 swift test --filter WalletBuildTests   # the output built for real (gated, a minute or two)
```

- **The record and the schema.** The package is found through Granite's roster with nothing listed; the schema, the
  field notes and the guide are what a model is shown; `Schema/wallet.input.schema.json` describes every field in the
  words the model sees, and `Schema/Wallet.md` lists every field, word, look role, string key, tuning key and launch
  state.
- **The lines.** Every kind of line (mappings, look, strings, tuning, launch), accepted and refused, each refusal with
  its reason; every key documented, unique and with a default that reads.
- **The templates.** Every template renders with every set of flags, with no marker and no placeholder left; every
  `{{key}}` is a tuning key and every tuning key is used; every word a template says is a string key and every key is
  said; every look role is read; every requirement a template reads is a role's; every type a part declares is listed
  for the prefix.
- **The files.** Which files and names a call writes; the Seer call's output (its file set, its conformance, its
  words, its look, its launch, the scorecard's code facts); the same bytes on a second call; the withdrawal on, soon
  and off; a later call that takes away what it no longer asks for; the prefix; the app's types checked against the
  lines; the notes.
- **A call through the roster.** The Seer call as a host makes it, JSON in and JSON out, and its answer is
  `Schema/examples/seer.answer.json` (`WALLET_EXAMPLES=1` writes it again).

## The gated build

`WalletBuildTests` writes four calls into a package of apps and builds them:

- **Seer, in Swift 6 and in Swift 5:** the Seer call (`Schema/examples/seer.json`) beside a SeerKit module with
  Seer's `Wallet`, `ModelEarning`, `CreditExchange` and `Cashout`, DesignAgent's names stood in (`Font.brandTitle`,
  `Font.brandBody2`, `Font.brandNote`, `Font.brandNote2`, `Color.accent`, `CGFloat.layer1` … `layer7`), and the page
  written as the prompt gives it, its relays stood in by classes of the same shape.
- **A reading app:** `Schema/examples/reading-points.json`, its own types in the same module, the prefix `Points`,
  the withdrawal on.
- **The least call:** no mapping, `withdraw: soon`.

It builds the package with `swift build` for the Mac with no warning in what the kit wrote, runs a check that reads
every conformance, word and launch state back and draws every view offscreen in light and dark, and builds the
package with `xcodebuild -destination 'generic/platform=iOS Simulator'`. No simulator is booted.

## Conformance on Seer

The call a model should write for Seer's wallet, `Schema/examples/seer.json`, sent with no model:

- it writes 23 files (19 of the kit, 4 conformances) and leaves the app no note;
- its output builds for the iPhone simulator in Swift 6 and Swift 5 beside SeerKit and the page body
  `WalletView(wallet: wallet.state.wallet, load: { try await wallet.load() }, close: { layout.closeSheet() })`;
- every `code` item of the scorecard's `wallet` area (`.work/measure/task/seer/scorecard.json` in Craft) matches it,
  B-wallet-7 to B-wallet-10; B-wallet-11 is the mock wallet's numbers, which are `$mocks`' to write;
- every word the spec quotes for the Wallet screen, All Exchanges and an exchange's sheet is in it.

The views mirror the original's subviews: the same composition, type, colour, material, spacing and motion, each
value a string, look or tuning key the call sets.
