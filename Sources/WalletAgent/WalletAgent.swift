//  WHAT: A credits wallet as a Granite agent package. A call names the app's types with one mapping line a role
//        (`wallet: Wallet balance=balance earned=earned groups=groups`), the look, the words, the numbers and the
//        launch states; the run writes plain SwiftUI into the folder the call names (the balance and the earnings,
//        three totals, the groups that earned, the exchanges that spent with See All, the cashouts, the sheets behind
//        them, a withdraw button), the protocols they read, the conformances that make the app's types those
//        protocols, and answers where, with the root view's initializer.
//  IN:   Input: the folder, the mapping lines and their modules, look, strings, tuning and launch lines, whether
//        there is a withdrawal, a prefix for the kit's names.
//  OUT:  WalletResult: the files written, the views, the conformances, the root's initializer, and what the app still
//        has to do.
//  PIN:  NO MODEL. Every file is made from the call, the same way every time; a line that is not understood is
//        refused with its reason, every reason at once, and nothing is written until every problem is fixed and
//        every file parses.
//  PIN:  THE VIEWS NEVER ROUTE. They take values and closures and hold no global state; the app presents the wallet
//        and closes it, and the kit presents only its own sheets.

import Foundation
import GraniteAgents

public struct WalletAgent: GraniteAgentPackage {
    public struct Input: Codable, Sendable {
        /// The folder the views go in, relative to the project; `Components/Wallet` when left out.
        public var into: String?
        /// One line a role: `wallet: Wallet balance=balance earned=earned spent=spent cashedOut=cashedOut groups=groups`.
        public var mappings: [String]?
        /// Modules the conformances import: where a mapped type lives.
        public var imports: [String]?
        /// The look roles mapped to the app's names, one a line: `title = Font.brandTitle`.
        public var look: [String]?
        /// The words, one a line: `title = Wallet`, `amount = %.4f cr`.
        public var strings: [String]?
        /// Numbers, sizes, symbols and motion, one a line: `groupCard = 150x120`.
        public var tuning: [String]?
        /// The states the root opens in for a `-destination` launch, one a line: `wallet.exchanges = exchanges`.
        public var launch: [String]?
        /// Whether there is a withdrawal: on (the default), soon or off.
        public var withdraw: WalletWithdraw?
        /// What the kit's names start with instead of `Wallet`, when the app already has those names.
        public var prefix: String?
        /// The host's folder.
        public var directory: String?

        public init(into: String? = nil, mappings: [String]? = nil, imports: [String]? = nil, look: [String]? = nil,
                    strings: [String]? = nil, tuning: [String]? = nil, launch: [String]? = nil, withdraw: WalletWithdraw? = nil,
                    prefix: String? = nil, directory: String? = nil) {
            self.into = into; self.mappings = mappings; self.imports = imports; self.look = look; self.strings = strings
            self.tuning = tuning; self.launch = launch; self.withdraw = withdraw; self.prefix = prefix; self.directory = directory
        }
    }

    public typealias Event = WalletFrame
    public typealias Output = WalletResult
    public typealias Compute = Void

    public static let word = "wallet"
    /// What it makes: the views a page shows, and the conformances that make the app's types theirs.
    public static let makes = [
        AgentMake(kind: "view", what: "a credits wallet as reusable SwiftUI views (WalletView, the root a page shows, and its hero, totals, cards, rows and sheets); a page shows it with WalletView(wallet:load:)",
                  into: ["Components/Wallet/*"], never: "routes; never a page, a service, a client or a model type"),
        AgentMake(kind: "conformance", what: "the app's own types made the wallet's: one extension a mapping line",
                  into: ["Components/Wallet/Conformances/*"], never: "a change to the app's types themselves"),
    ]
    public static let summary = "writes a credits wallet as plain SwiftUI (the balance and earnings, three totals, the groups that earned, the exchanges that spent with See All, the cashouts and the sheets behind them), made to show the app's own types from one mapping line a type."
    public static let fields = [
        "into": "the folder for the views, relative to the project; Components/Wallet when left out",
        "mappings": "one line a role (wallet, group, exchange, transaction): `wallet: Wallet balance=balance earned=earned spent=spent cashedOut=cashedOut groups=groups exchanges=exchanges transactions=cashouts`; a bare path is read off the value, anything else is Swift that may name `value`",
        "imports": "modules the conformances import, such as the package a mapped type is declared in",
        "look": "look roles mapped to the app's names, one a line: `title = Font.brandTitle`; roles title, heading, note, note2 (Font), accent, foreground, secondaryForeground, secondaryBackground, positive (Color), gutter (CGFloat); an unmapped role is the system's",
        "strings": "the words, one a line, `key = words` (quotes optional): `title = Wallet`, `amount = %.4f cr`, `groups.title = Model Groups`; every key and its default in Wallet.md",
        "tuning": "numbers, sizes, symbols and motion, one a line: `eyebrowTracking = 2.5`, `groupCard = 150x120`, `availableSymbol = arrow.up.circle.fill`, `amountAnimation = .easeOut(duration: 0.4)`; every key in Wallet.md",
        "launch": "the state the root opens in for a launch with `-destination <name>`, one a line: `wallet.exchanges = exchanges`; states wallet, exchanges, exchange, withdraw",
        "withdraw": "on (a Withdraw button, drawn when the page passes `withdraw:`, opening the withdrawal sheet; the default), soon (a faded button with \"Coming soon\") or off (none)",
        "prefix": "what the kit's names start with instead of Wallet, when the app already has those names: `Credits` writes CreditsView",
    ]
    public static let guide = """
        Tag wallet for a screen of credits, points or earnings: the balance and the earnings under small tracked \
        eyebrows, with what can be cashed out in green; a row of three totals (earned, spent, cashed out); a sideways \
        row of group cards (what each collection earned, its documents); a sideways row of exchange cards (what was \
        spent on what, and when) with See All and the sheets behind it; the cashouts; a withdraw button that can say \
        "Coming soon". It writes plain SwiftUI (iOS 17 and macOS 14) into `into` (Components/Wallet). The root is \
        `WalletView(wallet: Wallet?, load: { … })`: nil shows a spinner over "Loading wallet…", `load` is called as \
        it appears, and the app presents and closes it (pass `close:` for a close mark when the app draws none). \
        The views read four protocols, and `mappings` make the app's types conform, one line a role: \
        `role: Type word=value …`. Roles and their words: wallet (balance, earned, spent, cashedOut, earnings, \
        available, groups, exchanges, transactions); group (name, documents, earnings); exchange (title, date, cost, \
        fee, documents, savings, total); transaction (title, date, amount). earnings is earned and available is \
        earned less cashedOut when left out; an exchange's total is cost and savings. A list (groups, exchanges, \
        transactions) needs the line of its role for the type it holds. An amount may be a Double, a Decimal or an \
        Int, documents a count or a list that is counted, a date a Date or an ISO string. A type from a package \
        needs `imports`. A word left out takes a default, so map what the type has; a role no line maps uses the \
        kit's own value (WalletItem, WalletGroupItem, WalletExchangeItem, WalletTransactionItem). `look` maps the \
        look roles to the app's names (`title = Font.brandTitle`, `accent = Color.accent`, `gutter = CGFloat.layer7`); \
        `strings` sets any word by key (`amount = %.4f cr`, `balance.eyebrow = CREDIT BALANCE`, `groups.title = \
        Model Groups`, `exchange.title = Inference`; `{amount}` and `{count}` stand for what is said); `tuning` sets \
        any number, size, symbol or motion by key (`groupCard = 150x120`, `eyebrowTracking = 2.5`); `launch` opens a \
        state for `-destination <name>` (`wallet.exchanges = exchanges`: the See All sheet open). Example, a reading \
        app that pays authors in points, with its own types: {"mappings": ["wallet: Account balance=points \
        earned=lifetimePoints spent=spentPoints cashedOut=redeemed groups=shelves exchanges=purchases", "group: \
        Shelf name=title documents=books earnings=points", "exchange: Purchase title=bookTitle date=boughtAt \
        cost=price"], "strings": ["amount = %.0f pts", "groups.title = Your Shelves", "exchanges.title = Purchases"], \
        "withdraw": "soon"}. A line it cannot read is refused with the reason and nothing is written: fix the line \
        and call again. Not for the app's services, its network client or its model types.
        """

    public static func output(from events: [WalletFrame]) -> WalletResult? { events.compactMap(\.result).last }

    public init() {}

    public func run(_ input: Input, context: Context) -> AsyncThrowingStream<WalletFrame, Error> {
        // The folder is the call's, else the host's (a host over the wire may give it only there), else the
        // process's: never the runner's working folder while the host named one.
        var resolved = input
        if resolved.directory == nil { resolved.directory = context.host.directory }
        let call = resolved
        return AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    let result = try Self.write(call, note: context.host.note) { continuation.yield($0) }
                    continuation.yield(.written(result))
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    static let defaultFolder = "Components/Wallet"

    /// The whole call: the lines read, the kit planned and made, staged, checked and written.
    static func write(_ input: Input, note: @Sendable (String) -> Void, yield: (WalletFrame) -> Void) throws -> WalletResult {
        var problems: [String] = []
        let withdraw = input.withdraw ?? .on

        // The mapping lines, one type a role.
        var mappings: [Mapping] = []
        for line in input.mappings ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            do { mappings.append(try MappingLine.parse(line)) } catch { problems.append("\(error)") }
        }
        var roles: Set<WalletRole> = []
        for mapping in mappings where !roles.insert(mapping.role).inserted {
            problems.append("\(mapping.role.rawValue) is mapped twice: one type a role")
        }

        // The keyed lines, each key once.
        var look: [String: String] = [:], strings: [String: String] = [:], tuning: [String: String] = [:]
        var launches: [(destination: String, state: LaunchState)] = []
        func keyed<T>(_ field: String, _ lines: [String]?, _ parse: (String) -> Result<T, WalletError>, key: (T) -> String, take: (T) -> Void) {
            var seen: Set<String> = []
            for line in lines ?? [] where !line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                switch parse(line) {
                case .failure(let error): problems.append("\(field): \(error)")
                case .success(let value):
                    guard seen.insert(key(value)).inserted else { problems.append("\(field): `\(key(value))` is set twice: keep one line"); continue }
                    take(value)
                }
            }
        }
        keyed("look", input.look, { LookLine.parse($0, roles: WalletTables.look) }, key: { $0.role.key }) { look[$0.role.key] = $0.expression }
        keyed("strings", input.strings, { StringsLine.parse($0, keys: WalletTables.strings) }, key: { $0.key.key }) { strings[$0.key.key] = $0.text }
        keyed("tuning", input.tuning, { TuningLine.parse($0, keys: WalletTables.tuning) }, key: { $0.key.key }) { tuning[$0.key.key] = $0.value }
        keyed("launch", input.launch, { LaunchLine.parse($0, states: WalletTables.launch) }, key: { $0.destination }) {
            launches.append((destination: $0.destination, state: $0.state))
        }
        if withdraw != .on, launches.contains(where: { $0.state.name == "withdraw" }) {
            problems.append("launch: `withdraw` opens the withdrawal sheet, which `withdraw: \(withdraw.rawValue)` leaves out: say `withdraw: on`, or drop the line")
        }

        // The prefix and the modules.
        let named = (input.prefix ?? "").trimmingCharacters(in: .whitespaces)
        if !named.isEmpty, !SwiftName.isTypeName(named) {
            problems.append("`\(named)` is not a prefix for type names: UpperCamelCase letters and digits, like `Credits`")
        }
        let prefix = named.isEmpty || !SwiftName.isTypeName(named) ? KitCatalog.base : named
        var imports = (input.imports ?? []).map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
        for module in imports where !SwiftName.isModuleName(module) {
            problems.append("`\(module)` is not a module name")
        }

        // Each path checked against the app's own types, in their spelling; a type a local package declares imported.
        // The kit's own folder is not the app's: its previews declare sample values.
        let files = AgentFiles(directory: input.directory)
        let folder = files.resolve(input.into ?? defaultFolder)
        let app = AppTypes(root: files.root, excluding: folder)
        var notes: [String] = []
        var nothing: [String] = []
        mappings = mappings.map { mapping in
            // A property written as nothing is left out, so the protocol's default answers for it.
            let kept = mapping.assignments.filter { assignment in
                guard case .expression(let text) = assignment.source, assignment.property.kind.isNothing(text) else { return true }
                nothing.append("\(assignment.property.key)=\(text.trimmingCharacters(in: .whitespaces))")
                return false
            }
            return Mapping(line: mapping.line, role: mapping.role, type: mapping.type, assignments: kept)
        }
        if !nothing.isEmpty {
            notes.append("Left out \(nothing.joined(separator: ", ")): a property a line leaves out shows its default, so a line needs only what the type has.")
        }
        let roleTypes = Dictionary(mappings.map { ($0.role, $0.type) }, uniquingKeysWith: { first, _ in first })
        mappings = mappings.map { mapping in
            guard let declared = app.types[AppTypes.named(mapping.type)] else { return mapping }
            if let module = declared.module, !imports.contains(module), !mapping.type.hasPrefix(module + ".") {
                imports.append(module)
                notes.append("`\(mapping.type)` is declared in \(module), so the conformances import it.")
            }
            let assignments = mapping.assignments.map { assignment -> Mapping.Assignment in
                guard case .path(let path) = assignment.source else { return assignment }
                let property = assignment.property
                let (fixed, problem) = app.check(path, from: mapping.type)
                if let problem { problems.append("\(mapping.role.rawValue) \(property.key)=\(path): \(problem)"); return assignment }
                if fixed != path { notes.append("\(mapping.role.rawValue) \(property.key): `\(path)` is `\(fixed)` on \(declared.name).") }
                if let written = app.type(of: fixed, from: mapping.type) {
                    var base = written
                    while base.hasSuffix("?") || base.hasSuffix("!") { base.removeLast() }
                    let known = WalletKind.integers.union(["String", "Substring", "URL", "Double", "Float", "CGFloat", "Bool", "Date", "UUID", "Decimal"])
                    let declaredHere = app.types[AppTypes.named(base)] != nil && !base.hasPrefix("[")
                    if !property.kind.accepts(written), declaredHere || known.contains(base) || base.hasPrefix("[") {
                        problems.append("\(mapping.role.rawValue) \(property.key)=\(path): `\(fixed)` is `\(written)`, and `\(property.key)` shows "
                            + "\(property.kind.takesInWords): map a field of one of those, or leave `\(property.key)` out")
                        return assignment
                    }
                }
                // A list's items must be the type its role's line maps.
                if case .list(let role) = property.kind, let element = app.listElement(of: fixed, from: mapping.type),
                   let mapped = roleTypes[role], AppTypes.named(mapped) != element {
                    problems.append("wallet \(property.key)=\(path): `\(fixed)` holds \(element), and the \(role.rawValue) line maps \(mapped): "
                        + "map `\(role.rawValue): \(element) …`, or a list of \(mapped)")
                }
                return Mapping.Assignment(property: property, source: .path(fixed))
            }
            return Mapping(line: mapping.line, role: mapping.role, type: mapping.type, assignments: assignments)
        }
        // A list mapped needs the line of its role, so the views know the type it holds.
        if let wallet = mappings.first(where: { $0.role == .wallet }) {
            for assignment in wallet.assignments {
                guard case .list(let role) = assignment.property.kind, roleTypes[role] == nil else { continue }
                problems.append("wallet \(assignment.property.key)=… shows \(role.rawValue)s, and no `\(role.rawValue):` line says how: "
                    + "add one for the type the list holds (`\(role.rawValue): Type " + role.properties.prefix(2).map { "\($0.key)=…" }.joined(separator: " ") + "`)")
            }
            for role in WalletRole.allCases where role != .wallet && roleTypes[role] != nil {
                let list = WalletRole.wallet.properties.first { $0.kind == .list(role) }!
                if wallet.assignment(list.key) == nil {
                    notes.append("The \(role.rawValue) line maps \(roleTypes[role]!), and the wallet line maps no `\(list.key)`, so the wallet shows none: add `\(list.key)=…` to the wallet line.")
                }
            }
        } else if !mappings.isEmpty {
            notes.append("No `wallet:` line, so WalletView shows the kit's own \(WalletRole.wallet.itemType(prefix)), whose lists hold the kit's own values: map the app's wallet with `wallet: Type balance=…`.")
        }
        guard problems.isEmpty else { throw WalletError.problems(problems) }

        // The plan: the parts the call's flags allow, each number in its place.
        let amount = strings["amount"] ?? WalletTables.strings.first { $0.key == "amount" }!.text
        let plan = KitPlan(withdraw: withdraw, tuning: tuning, launched: Set(launches.map(\.state.name)),
                           unitLeads: StringsEmitter.amountParts(amount).leads)
        let flags = plan.flags
        let values = plan.values
        yield(.read(mappings: mappings.count, views: plan.views.count))
        note("writing \(plan.views.count) views into \(files.relative(folder))")

        let names = KitCatalog.names
        func renamed(_ text: String) -> String { TemplateRender.renaming(text, names: names, base: KitCatalog.base, prefix: prefix) }
        func file(_ name: String) -> String { prefix + name.dropFirst(KitCatalog.base.count) + ".swift" }
        var planned: [(url: URL, text: String)] = []
        for part in plan.parts {
            let text: String
            switch part.name {
            case "WalletProtocols": text = ProtocolsEmitter.emit()
            case "WalletLook": text = LookEmitter.emit(look)
            case "WalletStrings": text = StringsEmitter.emit(strings, flags: flags)
            case "WalletLaunch": text = LaunchEmitter.emit(launches, flags: flags)
            default: text = try TemplateRender.render(part.template, flags: flags, values: values)
            }
            planned.append((folder.appendingPathComponent(file(part.name)), renamed(text)))
        }
        let conformances = folder.appendingPathComponent("Conformances", isDirectory: true)
        for conformance in ConformanceEmitter.emit(mappings, imports: imports, prefix: prefix) {
            planned.append((conformances.appendingPathComponent(conformance.name), conformance.text))
        }

        // What an earlier call left that this one does not write: a part its flags drop, a conformance of a line it
        // no longer has.
        let manager = FileManager.default
        let plannedPaths = Set(planned.map(\.url.standardizedFileURL.path))
        var stale: [URL] = []
        for part in KitCatalog.parts {
            let url = folder.appendingPathComponent(file(part.name))
            if !plannedPaths.contains(url.standardizedFileURL.path), manager.fileExists(atPath: url.path) { stale.append(url) }
        }
        let protocols = WalletRole.allCases.map { $0.protocolName(prefix) }
        for name in ((try? manager.contentsOfDirectory(atPath: conformances.path)) ?? []).sorted() where name.hasSuffix(".swift") {
            let url = conformances.appendingPathComponent(name)
            guard !plannedPaths.contains(url.standardizedFileURL.path),
                  let text = try? String(contentsOf: url, encoding: .utf8),
                  protocols.contains(where: { text.contains(": \($0) {") }) else { continue }
            stale.append(url)
        }

        let existed = Set(planned.map(\.url.path).filter { manager.fileExists(atPath: $0) })
        let unchanged = Set(planned.filter { (try? String(contentsOf: $0.url, encoding: .utf8)) == $0.text }.map(\.url.path))
        let written = try files.write(planned)
        for url in stale { try? manager.removeItem(at: url) }
        note("wrote \(written.count) files" + (stale.isEmpty ? "" : ", took away \(stale.count)"))

        // What it was asked for: every view of the plan, and one conformance a mapping line. What it made: each of
        // those whose file was written, and each file taken away.
        func state(_ path: String) -> AgentMade.State { unchanged.contains(path) ? .unchanged : existed.contains(path) ? .rewritten : .written }
        func path(_ name: String) -> String? { written.first { ($0 as NSString).lastPathComponent == name } }
        let views = plan.views.map { prefix + $0.dropFirst(KitCatalog.base.count) }
        var expected = views.map { AgentExpected(kind: "view", name: $0) }
        expected += mappings.map { AgentExpected(kind: "conformance", name: $0.type) }
        var made: [AgentMade] = views.compactMap { view in path(view + ".swift").map { AgentMade(kind: "view", name: view, path: $0, state: state($0)) } }
        made += mappings.compactMap { mapping in
            path("\(mapping.fileStem)+\(mapping.role.name).swift").map { AgentMade(kind: "conformance", name: mapping.type, path: $0, state: state($0)) }
        }
        made += stale.map { url in
            let name = url.deletingPathExtension().lastPathComponent
            return AgentMade(kind: url.deletingLastPathComponent().lastPathComponent == "Conformances" ? "conformance" : "view",
                             name: name.components(separatedBy: "+").first ?? name, path: url.path, state: .removed)
        }

        let walletType = roleTypes[.wallet] ?? WalletRole.wallet.itemType(prefix)
        var root = "\(prefix)View(wallet: \(walletType)?, load: (() async throws -> Void)? = nil"
        if withdraw == .on { root += ", withdraw: ((\(prefix)Withdrawal) async throws -> Void)? = nil" }
        root += ", close: (() -> Void)? = nil)"
        if look.isEmpty {
            notes.append("No `look` lines: the views use the system's fonts and colours; map the app's with `look` (`title = Font.brandTitle`).")
        }
        if withdraw == .on {
            notes.append("The Withdraw button is drawn when the page passes `withdraw:`, which gets the account and the amount.")
        }
        for (key, _) in strings.sorted(by: { $0.key < $1.key }) {
            guard let part = WalletTables.strings.first(where: { $0.key == key })?.part, !flags.contains(part) else { continue }
            notes.append("`\(key)` is said only with `withdraw: \(part == "withdraw" ? "on` or `soon" : String(part.dropFirst("withdraw.".count)))`, so it is not written.")
        }
        return WalletResult(path: written.first, paths: written + stale.map(\.path), views: views,
                            conformances: mappings.map { "\($0.type): \($0.role.rawValue)" }, roots: [root], notes: notes,
                            made: made, expected: expected)
    }
}
