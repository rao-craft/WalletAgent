import Foundation
import GraniteAgents

/// What a call answers, as `granite-answer/1`: the files written, as absolute paths, what the app uses them by, and
/// what the call made of the views and mapping lines it was asked for.
public struct WalletResult: AgentAnswer, Equatable {
    /// The first file written.
    public var path: String?
    /// Every file written, then every file of an earlier call taken away.
    public var paths: [String]
    /// The views written, by type name, the root first.
    public var views: [String]
    /// One line a mapped type: `Wallet: wallet`.
    public var conformances: [String]
    /// The root view's initializer, as a line a page's body calls it by: `WalletView(wallet: Wallet?, close: …)`.
    public var roots: [String]
    /// One sentence each: what the call left out or the app still has to do, and why.
    public var notes: [String]
    /// Each view and conformance written, and each file taken away.
    public var made: [AgentMade]
    /// The views the call asked for, and one conformance a mapping line.
    public var expected: [AgentExpected]
    /// What it could only do in part.
    public var problems: [AgentProblem]

    public init(path: String?, paths: [String], views: [String], conformances: [String], roots: [String], notes: [String],
                made: [AgentMade] = [], expected: [AgentExpected] = [], problems: [AgentProblem] = []) {
        self.path = path; self.paths = paths; self.views = views; self.conformances = conformances; self.roots = roots
        self.notes = notes; self.made = made; self.expected = expected; self.problems = problems
    }
}
