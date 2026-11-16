//  WHAT: `WalletLaunch.swift`: the state the root view opens in when the app is launched with `-destination <name>`,
//        from the call's `launch` lines; with none, every launch is a plain one.

import Foundation

enum LaunchEmitter {
    static func emit(_ lines: [(destination: String, state: LaunchState)], flags: Set<String>) -> String {
        let states = WalletTables.launch.filter { state in state.part.map { flags.contains($0) } ?? true }
        var out = [
            "import Foundation",
            "",
            "/// Where the wallet opens when the app is launched with `-destination <name>`: how UI tests and screenshots reach",
            "/// a screen with no tap. The root view reads it once, as it appears, and opens its own sheets for it.",
            "enum WalletLaunch {",
            "    enum State: Equatable {",
        ]
        for state in states { out.append("        /// \(state.doc)") ; out.append("        case \(state.name)") }
        out += [
            "    }",
            "",
            "    /// The state the launch asks for, or nil for a plain launch.",
            "    static var state: State? {",
        ]
        if lines.isEmpty {
            out.append("        nil")
        } else {
            out.append("        switch UserDefaults.standard.string(forKey: \"destination\") {")
            for line in lines {
                out.append("        case \(SwiftName.literal(line.destination)): return .\(line.state.name)")
            }
            out += ["        default: return nil", "        }"]
        }
        out += ["    }", "}"]
        return TemplateRender.tidy(out)
    }
}
