//  WHAT: The mapping line, the one form a model says how an app's type shows in the wallet views (LoomAgent's):
//
//            wallet: Wallet balance=balance earned=earned spent=spent cashedOut=cashedOut groups=groups
//            group: ModelEarning name=name documents=documentIds earnings=earnings
//            exchange: CreditExchange date=createdAt cost=netCost fee=serviceFee savings=value.fee * 2
//
//        A role, a colon, the type, then one `word=right side` a thing the views show; spaces or commas between
//        them, and spaces around `=` are read too. A right side that is a bare path is read off the value;
//        anything else is Swift that may name `value`. A word the line leaves out takes the protocol's default.
//  PIN:  A LINE THAT IS NOT UNDERSTOOD IS REFUSED WITH THE REASON, and the reason lists what the role can map, so
//        the model can fix the line it is told about instead of guessing again.

import Foundation

enum MappingLine {
    static func parse(_ line: String) throws -> Mapping {
        let text = line.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw WalletError.line(line, "it is empty") }
        guard let colon = LineSplit.firstTop(text, ":") else {
            throw WalletError.line(line, "a mapping is `role: Type word=value …`, like `wallet: Wallet balance=balance`, and this has no colon")
        }
        let head = text[..<colon].trimmingCharacters(in: .whitespaces)
        guard let role = WalletRole.named(head) else {
            throw WalletError.line(line, "`\(head)` is not a role: a line starts with wallet, group, exchange or transaction")
        }
        let rest = text[text.index(after: colon)...].trimmingCharacters(in: .whitespaces)
        let typeEnd = rest.firstIndex { $0 == " " || $0 == "," } ?? rest.endIndex
        let type = String(rest[..<typeEnd])
        guard !type.isEmpty else { throw WalletError.line(line, "it names no type: `\(role.rawValue): \(role.name) \(role.properties[0].key)=\(role.properties[0].key)`") }
        guard SwiftName.isTypePath(type) else {
            throw WalletError.line(line, "`\(type)` is not a type name (UpperCamelCase, dots between a module and its type, no generic arguments)")
        }

        var assignments: [Mapping.Assignment] = []
        var seen: Set<String> = []
        for piece in pieces(String(rest[typeEnd...])) {
            guard let equals = piece.firstIndex(of: "=") else {
                throw WalletError.line(line, "`\(piece)` is not `word=value`")
            }
            let word = piece[..<equals].trimmingCharacters(in: .whitespaces)
            let value = piece[piece.index(after: equals)...].trimmingCharacters(in: .whitespaces)
            guard !value.isEmpty else { throw WalletError.line(line, "`\(word)` has `=` and no value") }
            guard let property = role.property(named: word) else {
                throw WalletError.line(line, "`\(word)` is not something a \(role.rawValue) shows; a \(role.rawValue) maps " + role.properties.map(\.key).joined(separator: ", "))
            }
            guard seen.insert(property.key).inserted else {
                throw WalletError.line(line, "`\(property.key)` is mapped twice")
            }
            assignments.append(.init(property: property, source: Self.source(value)))
        }
        guard !assignments.isEmpty else {
            throw WalletError.line(line, "it maps nothing: say what the views show, like `\(role.rawValue): \(type) \(role.properties[0].key)=\(role.properties[0].key)`")
        }
        return Mapping(line: line, role: role, type: type, assignments: assignments)
    }

    /// `name=title earnings=stats.earned ?? 0, documents = docs` cut where each `word=` begins at the top level:
    /// after a space or a comma, outside brackets and quotes, and never at `==`, `!=`, `<=` or `>=`.
    static func pieces(_ text: String) -> [String] {
        let characters = Array(text)
        var starts: [Int] = []
        var depth = 0, quoted = false, escaped = false
        for index in characters.indices {
            let character = characters[index]
            if quoted {
                if escaped { escaped = false } else if character == "\\" { escaped = true } else if character == "\"" { quoted = false }
                continue
            }
            switch character {
            case "\"": quoted = true
            case "[", "(", "{": depth += 1
            case "]", ")", "}": depth = max(0, depth - 1)
            default:
                guard depth == 0, character.isLetter || character == "_" else { continue }
                let before = index == 0 ? " " : characters[index - 1]
                guard before == " " || before == "," || before == "\t" else { continue }
                if assignmentStarts(characters, at: index) { starts.append(index) }
            }
        }
        var pieces: [String] = []
        for (number, start) in starts.enumerated() {
            let end = number + 1 < starts.count ? starts[number + 1] : characters.count
            var piece = String(characters[start..<end]).trimmingCharacters(in: .whitespaces)
            while piece.hasSuffix(",") { piece = String(piece.dropLast()).trimmingCharacters(in: .whitespaces) }
            if !piece.isEmpty { pieces.append(piece) }
        }
        // Text before the first word (a stray token after the type) is a piece of its own, so it is refused.
        let lead = String(characters[0..<(starts.first ?? characters.count)]).trimmingCharacters(in: CharacterSet(charactersIn: " ,\t"))
        return lead.isEmpty ? pieces : [lead] + pieces
    }

    /// Whether `word=` (an identifier, spaces, one `=`) begins at `index`.
    private static func assignmentStarts(_ characters: [Character], at index: Int) -> Bool {
        var cursor = index
        while cursor < characters.count, characters[cursor].isLetter || characters[cursor].isNumber || characters[cursor] == "_" { cursor += 1 }
        while cursor < characters.count, characters[cursor] == " " { cursor += 1 }
        guard cursor < characters.count, characters[cursor] == "=" else { return false }
        return cursor + 1 >= characters.count || characters[cursor + 1] != "="
    }

    /// A bare path read off the value, or Swift that names `value`.
    static func source(_ value: String) -> Mapping.Source {
        var path = value
        for root in ["self.", "value."] where path.hasPrefix(root) { path = String(path.dropFirst(root.count)) }
        let isPath = path.range(of: #"^[A-Za-z_][A-Za-z0-9_]*(\??\.[A-Za-z_][A-Za-z0-9_]*)*$"#, options: .regularExpression) != nil
        guard isPath, !["true", "false", "nil", "self", "value", "Self"].contains(path) else { return .expression(value) }
        return .path(path)
    }
}
