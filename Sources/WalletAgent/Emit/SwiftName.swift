//  WHAT: What Swift accepts as a name, and words written as Swift string literals.

import Foundation

enum SwiftName {
    static func isTypeName(_ text: String) -> Bool {
        text.range(of: #"^[A-Z][A-Za-z0-9_]*$"#, options: .regularExpression) != nil
    }

    /// `Wallet`, `SeerKit.Wallet`: type names joined by dots.
    static func isTypePath(_ text: String) -> Bool {
        !text.isEmpty && text.split(separator: ".", omittingEmptySubsequences: false).allSatisfy { isTypeName(String($0)) }
    }

    /// `SeerKit`, `Foundation`: what an `import` names.
    static func isModuleName(_ text: String) -> Bool {
        text.range(of: #"^[A-Za-z_][A-Za-z0-9_]*$"#, options: .regularExpression) != nil
    }

    /// `text` as the inside of a Swift string literal: backslashes, quotes and line breaks escaped, so no word a call
    /// gives can end the literal or interpolate.
    static func escaped(_ text: String) -> String {
        var out = ""
        for character in text {
            switch character {
            case "\\": out += "\\\\"
            case "\"": out += "\\\""
            case "\n": out += "\\n"
            case "\r": out += "\\r"
            case "\t": out += "\\t"
            default: out.append(character)
            }
        }
        return out
    }

    /// `text` as a Swift string literal, each `{name}` in `placeholders` interpolated: `"\(amount) available"`.
    static func literal(_ text: String, placeholders: [String] = []) -> String {
        guard !placeholders.isEmpty else { return "\"" + escaped(text) + "\"" }
        var out = "\"", rest = Substring(text)
        while let open = rest.firstIndex(of: "{") {
            guard let close = rest[open...].firstIndex(of: "}") else { break }
            let name = String(rest[rest.index(after: open)..<close])
            guard placeholders.contains(name) else {
                out += escaped(String(rest[...open])); rest = rest[rest.index(after: open)...]; continue
            }
            out += escaped(String(rest[..<open])) + "\\(" + name + ")"
            rest = rest[rest.index(after: close)...]
        }
        return out + escaped(String(rest)) + "\""
    }
}
