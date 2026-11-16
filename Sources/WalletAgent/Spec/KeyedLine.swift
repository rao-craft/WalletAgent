//  WHAT: The lines that set something by name, `key = value`: a look role to the app's name for it, a word, a
//        number or a symbol, a destination to the state the kit opens in. Each kind has its own reader; they share
//        how a line is cut.
//  PIN:  A KEY THAT IS NOT KNOWN IS REFUSED WITH THE KEYS THAT ARE, and a value that does not read with what the
//        key takes, so a line is fixed once.

import Foundation

enum KeyedLine {
    /// `key = value` cut at its first `=`, both sides trimmed; nil when there is no `=` or either side is empty.
    static func split(_ line: String) -> (key: String, value: String)? {
        let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let equals = text.firstIndex(of: "=") else { return nil }
        let key = text[..<equals].trimmingCharacters(in: .whitespaces)
        let value = text[text.index(after: equals)...].trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty, !value.isEmpty else { return nil }
        return (key, value)
    }

    /// The known key a line's key names, any case.
    static func find<T>(_ key: String, in table: [T], by name: (T) -> String) -> T? {
        table.first { name($0) == key } ?? table.first { name($0).lowercased() == key.lowercased() }
    }

    /// `a, b and c`, for a refusal that lists what is accepted.
    static func list(_ words: [String]) -> String {
        guard words.count > 1 else { return words.first ?? "" }
        return words.dropLast().joined(separator: ", ") + " and " + words[words.count - 1]
    }
}

// MARK: - Look

/// A look role the views read, and what it falls back to: `title`, a `Font`, `.headline` when unmapped.
struct LookRole: Sendable {
    enum Kind: String, Sendable { case font = "Font", color = "Color", length = "CGFloat" }
    let key: String
    let kind: Kind
    /// The system value an unmapped role falls back to: an expression, or a body of several lines.
    let fallback: String
    let doc: String

    init(_ key: String, _ kind: Kind, _ fallback: String, _ doc: String) {
        self.key = key; self.kind = kind; self.fallback = fallback; self.doc = doc
    }
}

enum LookLine {
    /// `title = Font.brandTitle`: the role, and the app's name for it as Swift.
    static func parse(_ line: String, roles: [LookRole]) -> Result<(role: LookRole, expression: String), WalletError> {
        guard let (key, value) = KeyedLine.split(line) else {
            return .failure(.line(line, "a look line is `role = the app's name`, like `title = Font.brandTitle` or `accent = Color.accent`"))
        }
        guard let role = KeyedLine.find(key, in: roles, by: \.key) else {
            return .failure(.line(line, "`\(key)` is not a look role; the roles are " + KeyedLine.list(roles.map(\.key))))
        }
        guard shaped(value, as: role.kind) else {
            let example = role.kind == .font ? "`Font.brandTitle` or `.headline`" : role.kind == .color ? "`Color.accent` or `.green`" : "`CGFloat.layer4` or `16`"
            return .failure(.line(line, "`\(role.key)` is a \(role.kind.rawValue), so it reads as \(example), not `\(value)`"))
        }
        return .success((role, value))
    }

    /// Whether `value` reads as Swift for a role of `kind`: an implicit member, or one of the type's.
    static func shaped(_ value: String, as kind: LookRole.Kind) -> Bool {
        if value.hasPrefix("\"") || value.contains("\n") { return false }
        if value.range(of: #"^\.[a-z][A-Za-z0-9_]*"#, options: .regularExpression) != nil { return true }
        switch kind {
        case .font: return value.hasPrefix("Font.") || value.hasPrefix("Font(") || value.hasPrefix("SwiftUI.Font.")
        case .color: return value.hasPrefix("Color.") || value.hasPrefix("Color(") || value.hasPrefix("SwiftUI.Color.")
        case .length:
            return value.hasPrefix("CGFloat.") || value.hasPrefix("CGFloat(")
                || value.range(of: #"^\d+(\.\d+)?$"#, options: .regularExpression) != nil
        }
    }
}

// MARK: - Strings

/// A user-facing word the views say, by key, with its natural English default. `{amount}`, `{count}` and
/// `{level}` stand for what is said in it; a key ending `.one` is its key's form for exactly one.
struct StringKey: Sendable {
    let key: String
    let text: String
    let doc: String
    /// The template flag that must hold for it to be written (`withdraw.on`); nil: always.
    let part: String?

    init(_ key: String, _ text: String, _ doc: String, part: String? = nil) {
        self.key = key; self.text = text; self.doc = doc; self.part = part
    }

    /// Its member in the strings enum: `group.documents` is `groupDocuments`.
    var member: String { StringKey.member(key) }

    /// Whether it is another key's form for one.
    var isSingular: Bool { key.hasSuffix(".one") }

    /// The `{name}`s in its default, in order.
    var placeholders: [String] { StringKey.placeholders(in: text) }

    static func member(_ key: String) -> String {
        let parts = key.split(separator: ".").map(String.init)
        return parts.enumerated().map { index, part in index == 0 ? part : part.prefix(1).uppercased() + part.dropFirst() }.joined()
    }

    static func placeholders(in text: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: #"\{([a-z]+)\}"#) else { return [] }
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
            Range($0.range(at: 1), in: text).map { String(text[$0]) }
        }
    }
}

enum StringsLine {
    /// `title = Wallet` or `title = "Wallet"`: the key, and the words (a quoted value may use `\n` and `\"`; an
    /// unquoted one is taken as written, `\n` read as a line break).
    static func parse(_ line: String, keys: [StringKey]) -> Result<(key: StringKey, text: String), WalletError> {
        guard let (name, raw) = KeyedLine.split(line) else {
            return .failure(.line(line, "a strings line is `key = words`, like `title = Wallet`"))
        }
        guard let key = KeyedLine.find(name, in: keys, by: \.key) else {
            return .failure(.line(line, "`\(name)` is not a string key; the keys are " + KeyedLine.list(keys.map(\.key))))
        }
        let text = unquoted(raw)
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return .failure(.line(line, "`\(key.key)` is empty: say it in words, or leave the line out for \"\(key.text)\""))
        }
        if key.key == "amount" {
            let specifiers = text.count(matching: #"%[0-9]*(\.[0-9]+)?f"#)
            let others = text.replacingOccurrences(of: #"%[0-9]*(\.[0-9]+)?f"#, with: "", options: .regularExpression).replacingOccurrences(of: "%%", with: "")
            guard specifiers == 1, !others.contains("%") else {
                return .failure(.line(line, "`amount` is how every amount reads: one number format with its unit, like `%.4f cr` or `$%.2f`"))
            }
            return .success((key, text))
        }
        let wanted = Set(key.placeholders), given = Set(StringKey.placeholders(in: text))
        guard wanted == given else {
            let say = wanted.isEmpty ? "says no `{…}`" : "says " + KeyedLine.list(key.placeholders.map { "`{\($0)}`" })
            return .failure(.line(line, "`\(key.key)` \(say), as \"\(key.text)\" does"))
        }
        return .success((key, text))
    }

    /// A quoted value's escapes read; an unquoted value as written, with `\n` a line break.
    static func unquoted(_ raw: String) -> String {
        guard raw.count >= 2, raw.hasPrefix("\""), raw.hasSuffix("\"") else { return raw.replacingOccurrences(of: "\\n", with: "\n") }
        var out = "", escaped = false
        for character in raw.dropFirst().dropLast() {
            if escaped {
                switch character {
                case "n": out.append("\n")
                case "t": out.append("\t")
                default: out.append(character)
                }
                escaped = false
            } else if character == "\\" {
                escaped = true
            } else {
                out.append(character)
            }
        }
        return out
    }
}

// MARK: - Tuning

/// A number, size, symbol, design, material or motion the views use, by key, with its default.
struct TuningKey: Sendable {
    enum Kind: String, Sendable {
        case number, integer, size, symbol, design, material, animation

        var inWords: String {
            switch self {
            case .number: return "a number, like 2.5"
            case .integer: return "a whole number, like 240"
            case .size: return "a size, width x height, like 150x120"
            case .symbol: return "an SF Symbol's name, like arrow.up.circle.fill"
            case .design: return "a font design: default, serif, rounded or monospaced"
            case .material: return "a material: ultraThin, thin, regular, thick or ultraThick"
            case .animation: return "an animation as SwiftUI writes it, like .easeOut(duration: 0.4) or .spring(response: 0.4, dampingFraction: 0.8)"
            }
        }
    }

    let key: String
    let kind: Kind
    /// The default, written as a line would write it.
    let value: String
    let doc: String
    let part: String?

    init(_ key: String, _ kind: Kind, _ value: String, _ doc: String, part: String? = nil) {
        self.key = key; self.kind = kind; self.value = value; self.doc = doc; self.part = part
    }
}

enum TuningLine {
    /// `groupCard = 150x120`: the key, and the value as the line wrote it, made regular.
    static func parse(_ line: String, keys: [TuningKey]) -> Result<(key: TuningKey, value: String), WalletError> {
        guard let (name, raw) = KeyedLine.split(line) else {
            return .failure(.line(line, "a tuning line is `key = value`, like `groupCard = 150x120` or `eyebrowTracking = 2.5`"))
        }
        guard let key = KeyedLine.find(name, in: keys, by: \.key) else {
            return .failure(.line(line, "`\(name)` is not a tuning key; the keys are " + KeyedLine.list(keys.map(\.key))))
        }
        guard let value = regular(raw, as: key.kind) else {
            return .failure(.line(line, "`\(key.key)` takes \(key.kind.inWords), not `\(raw)`"))
        }
        return .success((key, value))
    }

    /// The value made regular for its kind, or nil when it does not read as one.
    static func regular(_ raw: String, as kind: TuningKey.Kind) -> String? {
        let text = raw.trimmingCharacters(in: CharacterSet(charactersIn: " \"")).trimmingCharacters(in: .whitespaces)
        let number = #"\d+(?:\.\d+)?"#
        switch kind {
        case .number:
            return text.range(of: "^\(number)$", options: .regularExpression) != nil ? text : nil
        case .integer:
            return text.range(of: #"^\d+$"#, options: .regularExpression) != nil ? text : nil
        case .size:
            let parts = text.lowercased().replacingOccurrences(of: "×", with: "x").split(separator: "x").map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2, parts.allSatisfy({ $0.range(of: "^\(number)$", options: .regularExpression) != nil }) else { return nil }
            return "\(parts[0])x\(parts[1])"
        case .symbol:
            return text.range(of: #"^[a-z0-9]+(\.[a-z0-9]+)*$"#, options: .regularExpression) != nil ? text : nil
        case .design:
            return ["default", "serif", "rounded", "monospaced"].first { $0 == text.lowercased() }
        case .material:
            return ["ultraThin", "thin", "regular", "thick", "ultraThick"].first { $0.lowercased() == text.lowercased().replacingOccurrences(of: "material", with: "") }
        case .animation:
            let body = text.hasPrefix(".") ? String(text.dropFirst()) : text
            let forms = [
                "^(easeOut|easeIn|easeInOut|linear)\\(duration: ?\(number)\\)$",
                "^spring\\(response: ?\(number), ?dampingFraction: ?\(number)\\)$",
                "^spring\\(duration: ?\(number)(, ?bounce: ?\(number))?\\)$",
                "^(smooth|snappy|bouncy|default|easeOut|easeIn|easeInOut|linear|spring)$",
            ]
            guard forms.contains(where: { body.range(of: $0, options: .regularExpression) != nil }) else { return nil }
            return "." + body.replacingOccurrences(of: ":(?! )", with: ": ", options: .regularExpression)
                .replacingOccurrences(of: ",(?! )", with: ", ", options: .regularExpression)
        }
    }

    /// What a template's `{{…}}` placeholders become for one key: `{{groupCard.width}}` and `{{groupCard.height}}`
    /// for a size, `{{material}}` as `regularMaterial`, the value itself otherwise.
    static func placeholders(_ key: TuningKey, value: String) -> [String: String] {
        switch key.kind {
        case .size:
            let parts = value.split(separator: "x").map(String.init)
            return [key.key + ".width": parts[0], key.key + ".height": parts[1]]
        case .material:
            return [key.key: value + "Material"]
        default:
            return [key.key: value]
        }
    }
}

// MARK: - Launch

/// A state the kit's root view can open in when the app is launched with `-destination <name>`.
struct LaunchState: Sendable {
    let name: String
    /// Whether it takes ids in parentheses: `graph(space-001, space-002)`.
    let takesIDs: Bool
    let doc: String
    let part: String?

    init(_ name: String, takesIDs: Bool = false, _ doc: String, part: String? = nil) {
        self.name = name; self.takesIDs = takesIDs; self.doc = doc; self.part = part
    }
}

enum LaunchLine {
    /// `wallet.exchanges = exchanges`: the destination, the state, and its ids when it takes them.
    static func parse(_ line: String, states: [LaunchState]) -> Result<(destination: String, state: LaunchState, ids: [String]), WalletError> {
        guard let (destination, raw) = KeyedLine.split(line) else {
            return .failure(.line(line, "a launch line is `destination = state`, like `wallet.exchanges = exchanges`"))
        }
        guard destination.range(of: #"^[A-Za-z0-9][A-Za-z0-9._-]*$"#, options: .regularExpression) != nil else {
            return .failure(.line(line, "`\(destination)` is not a destination name: letters, digits, dots, dashes and underscores, like `wallet.exchanges`"))
        }
        var name = raw, ids: [String] = []
        if let open = raw.firstIndex(of: "("), raw.hasSuffix(")") {
            name = raw[..<open].trimmingCharacters(in: .whitespaces)
            let inside = raw[raw.index(after: open)..<raw.index(before: raw.endIndex)]
            ids = LineSplit.top(String(inside), on: ",").map { $0.trimmingCharacters(in: CharacterSet(charactersIn: " \"")) }.filter { !$0.isEmpty }
        }
        guard let state = states.first(where: { $0.name == name }) else {
            return .failure(.line(line, "`\(name)` is not a state the kit opens in; the states are " + KeyedLine.list(states.map(\.name))))
        }
        if !ids.isEmpty, !state.takesIDs {
            return .failure(.line(line, "`\(state.name)` takes nothing in parentheses: `\(destination) = \(state.name)`"))
        }
        return .success((destination, state, ids))
    }
}

extension String {
    /// How many times `pattern` matches.
    func count(matching pattern: String) -> Int {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return 0 }
        return regex.numberOfMatches(in: self, range: NSRange(startIndex..., in: self))
    }
}
