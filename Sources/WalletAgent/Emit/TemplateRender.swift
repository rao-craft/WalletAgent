//  WHAT: A template made into the app's file: the blocks a call did not ask for dropped, each `{{key}}` given the
//        call's number, size, symbol or motion, and the kit's type names given the call's prefix. A template is
//        Swift as it is written with every part asked for; its conditions are comment lines (LoomAgent's):
//
//            //@if withdraw.on || launch.exchanges
//            //@else
//            //@endif
//
//        and its tuning is written where a person would write the number: `.frame(width: {{groupCard.width}},
//        height: {{groupCard.height}})` becomes `.frame(width: 150, height: 120)`.
//  PIN:  A MARKER IS A LINE OF ITS OWN and never reaches the app, and a placeholder with no value is a fault of the
//        template: both are caught by the tests before any call is made.

import Foundation

enum TemplateRender {
    enum Failure: Error, Equatable { case unbalanced(String), unfilled(String) }

    /// `source` with every block whose condition is false dropped, the marker lines gone, and each `{{key}}` filled.
    static func render(_ source: String, flags: Set<String>, values: [String: String] = [:]) throws -> String {
        var output: [Substring] = []
        // Each open block: whether its branch is kept, and whether the block as a whole sits in a kept branch.
        var stack: [(keeping: Bool, parent: Bool)] = []
        var keeping = true
        for line in source.split(separator: "\n", omittingEmptySubsequences: false) {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("//@if ") {
                let condition = holds(String(trimmed.dropFirst(6)), flags: flags)
                stack.append((keeping && condition, keeping))
                keeping = keeping && condition
            } else if trimmed == "//@else" {
                guard let top = stack.popLast() else { throw Failure.unbalanced("//@else without //@if") }
                stack.append((top.parent && !top.keeping, top.parent))
                keeping = top.parent && !top.keeping
            } else if trimmed == "//@endif" {
                guard let top = stack.popLast() else { throw Failure.unbalanced("//@endif without //@if") }
                keeping = top.parent
            } else if keeping {
                output.append(line)
            }
        }
        guard stack.isEmpty else { throw Failure.unbalanced("\(stack.count) //@if without //@endif") }
        return try fill(tidy(output.map(String.init)), values: values)
    }

    /// `text` with each `{{key}}` replaced by its value.
    static func fill(_ text: String, values: [String: String]) throws -> String {
        guard text.contains("{{") else { return text }
        var out = "", rest = Substring(text)
        while let open = rest.range(of: "{{") {
            out += rest[..<open.lowerBound]
            guard let close = rest[open.upperBound...].range(of: "}}") else { throw Failure.unfilled(String(rest[open.lowerBound...].prefix(40))) }
            let key = String(rest[open.upperBound..<close.lowerBound])
            guard let value = values[key] else { throw Failure.unfilled(key) }
            out += value
            rest = rest[close.upperBound...]
        }
        return out + rest
    }

    /// The `{{key}}`s a template uses.
    static func placeholders(in text: String) -> Set<String> {
        Set(text.matchesOf(#"\{\{([A-Za-z0-9_.]+)\}\}"#))
    }

    /// The lines as a file: no trailing spaces, no run of blank lines and no blank line against a brace (where a
    /// dropped block leaves them), one newline at the end.
    static func tidy(_ lines: [String]) -> String {
        var kept: [String] = []
        for (index, raw) in lines.enumerated() {
            var line = raw
            while line.last == " " || line.last == "\t" { line.removeLast() }
            if line.isEmpty {
                let next = lines[(index + 1)...].first { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
                let afterOpening = kept.last.map { $0.hasSuffix("{") } ?? true
                let beforeClosing = next.map { $0.trimmingCharacters(in: .whitespaces).hasPrefix("}") } ?? true
                if kept.last?.isEmpty == true || afterOpening || beforeClosing { continue }
            }
            kept.append(line)
        }
        return kept.joined(separator: "\n") + "\n"
    }

    /// `a || b && !c`: `&&` binds tighter than `||`; a name holds when it is in `flags`.
    static func holds(_ condition: String, flags: Set<String>) -> Bool {
        condition.components(separatedBy: "||").contains { any in
            any.components(separatedBy: "&&").allSatisfy { term in
                let word = term.trimmingCharacters(in: .whitespaces)
                return word.hasPrefix("!") ? !flags.contains(String(word.dropFirst())) : flags.contains(word)
            }
        }
    }

    /// `text` with each of the kit's names (a whole word that starts with `base`) given `prefix` in its place:
    /// `WalletHeroView` → `CreditsHeroView`.
    static func renaming(_ text: String, names: [String], base: String, prefix: String) -> String {
        guard prefix != base, !names.isEmpty else { return text }
        let pattern = "(?<![A-Za-z0-9_])" + NSRegularExpression.escapedPattern(for: base) + "("
            + names.map { String($0.dropFirst(base.count)) }.sorted { $0.count > $1.count }.map(NSRegularExpression.escapedPattern(for:)).joined(separator: "|")
            + ")(?![A-Za-z0-9_])"
        guard let expression = try? NSRegularExpression(pattern: pattern) else { return text }
        let range = NSRange(text.startIndex..., in: text)
        return expression.stringByReplacingMatches(in: text, range: range, withTemplate: NSRegularExpression.escapedTemplate(for: prefix) + "$1")
    }
}

extension String {
    /// The first capture of every match of `pattern`.
    func matchesOf(_ pattern: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: self, range: NSRange(startIndex..., in: self)).compactMap { Range($0.range(at: 1), in: self).map { String(self[$0]) } }
    }
}
