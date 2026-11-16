import Foundation
import GraniteAgents
import XCTest
@testable import WalletAgent

/// The package as an app finds it: by its record, with the schema a model is shown and the guide a host prompts with.
final class WalletAgentTests: XCTestCase {
    func testTheRecordIsFoundWithNothingListed() throws {
        let wallet = try XCTUnwrap(GraniteRoster.discovered().package("wallet"), "the record is in this test binary")
        XCTAssertEqual(wallet.module, "WalletAgent")
        XCTAssertEqual(wallet.summary, WalletAgent.summary)
    }

    func testTheSchemaIsWhatAModelIsShown() {
        let wallet = AnyAgentPackage(WalletAgent.self)
        XCTAssertEqual(wallet.schema, .object([
            .init(name: "into", schema: .string, required: false),
            .init(name: "mappings", schema: .array(.string), required: false),
            .init(name: "imports", schema: .array(.string), required: false),
            .init(name: "look", schema: .array(.string), required: false),
            .init(name: "strings", schema: .array(.string), required: false),
            .init(name: "tuning", schema: .array(.string), required: false),
            .init(name: "launch", schema: .array(.string), required: false),
            .init(name: "withdraw", schema: .choice(["on", "soon", "off"]), required: false),
            .init(name: "prefix", schema: .string, required: false),
            .init(name: "directory", schema: .string, required: false),
        ]))
        XCTAssertTrue(wallet.takesDirectory)
        XCTAssertEqual(Set(wallet.fields.keys), ["into", "mappings", "imports", "look", "strings", "tuning", "launch", "withdraw", "prefix"],
                       "a note beside every field the model sees")
    }

    func testTheGuideTeachesTheLinesAndTheRoot() {
        let guide = AnyAgentPackage(WalletAgent.self).guide
        for word in ["mappings", "wallet (", "group (", "exchange (", "transaction (", "value", "imports", "look", "strings",
                     "tuning", "launch", "withdraw", "WalletView(wallet:", "load:", "close:", "Loading wallet…", "-destination"] {
            XCTAssertTrue(guide.contains(word), "the guide says \(word)")
        }
        // Every word a role maps is in the guide, so the model never has to guess one.
        for role in WalletRole.allCases {
            for property in role.properties { XCTAssertTrue(guide.contains(property.key), "the guide names \(role).\(property.key)") }
        }
        XCTAssertEqual(guide.components(separatedBy: "{\"").count - 1, 1, "one example call")
        XCTAssertFalse(guide.contains("Seer"), "no app's names to copy")
    }

    /// The Seer call as a host makes it: JSON in, the host's folder filled, JSON out naming the files and the root.
    func testTheSeerCallThroughTheRosterWritesTheFilesItNames() async throws {
        let folder = try Fixture.folder()
        let call = try Data(contentsOf: Fixture.package.appendingPathComponent("Schema/examples/seer.json"))
        let answer = try await AnyAgentPackage(WalletAgent.self).perform(call, host: AgentHost(directory: folder.path, ask: "the wallet"))
        let result = try JSONDecoder().decode(WalletResult.self, from: answer)
        let kit = folder.appendingPathComponent("Components/Wallet").path
        XCTAssertEqual(result.path, result.paths.first)
        for path in result.paths {
            XCTAssertTrue(path.hasPrefix(kit + "/"), path)
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), path)
        }
        XCTAssertEqual(result.conformances, ["Wallet: wallet", "ModelEarning: group", "CreditExchange: exchange", "Cashout: transaction"])
        XCTAssertEqual(result.roots, ["WalletView(wallet: Wallet?, load: (() async throws -> Void)? = nil, close: (() -> Void)? = nil)"])
        XCTAssertEqual(result.views.first, "WalletView")
        XCTAssertEqual(Set(result.made.map(\.kind)), ["view", "conformance"])
        XCTAssertEqual(result.made.filter { $0.kind == "view" }.count, result.views.count, "every view asked for is made")
        XCTAssertEqual(Set(result.expected.map(\.name)), Set(result.made.map(\.name)))
        XCTAssertEqual(result.notes, [], "the Seer call leaves nothing for the app to do but call the root")
    }

    /// A host over the wire may name its folder only in `AgentHost`: every file lands there all the same.
    func testTheHostsFolderIsUsedWhenTheCallNamesNone() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: ["withdraw": "soon"])
        let answer = try await AnyAgentPackage(WalletAgent.self).perform(input, host: AgentHost(directory: folder.path))
        let result = try JSONDecoder().decode(WalletResult.self, from: answer)
        XCTAssertFalse(result.paths.isEmpty)
        for path in result.paths {
            XCTAssertTrue(path.hasPrefix(folder.path + "/"), "\(path) is not under the host's folder")
            XCTAssertTrue(FileManager.default.fileExists(atPath: path), path)
        }
        XCTAssertEqual(result.roots, ["WalletView(wallet: WalletItem?, load: (() async throws -> Void)? = nil, close: (() -> Void)? = nil)"])
    }

    /// A call that cannot be read is refused as the call's to fix, every reason at once.
    func testARefusalIsTheCallsWithEveryReason() async throws {
        let folder = try Fixture.folder()
        let input = try JSONSerialization.data(withJSONObject: [
            "mappings": ["wallet Wallet balance=balance"], "strings": ["colour = red"], "tuning": ["groupCard = big"],
        ])
        do {
            _ = try await AnyAgentPackage(WalletAgent.self).perform(input, host: AgentHost(directory: folder.path))
            XCTFail("refused")
        } catch {
            let text = "\(error)"
            for reason in ["has no colon", "`colour` is not a string key", "`groupCard` takes a size"] {
                XCTAssertTrue(text.contains(reason), "\(reason) in \(text)")
            }
        }
        XCTAssertEqual(try FileManager.default.contentsOfDirectory(atPath: folder.path), [], "nothing was written")
    }

    /// The input schema the repository ships describes every field the model sees, in the words the model is shown.
    func testTheShippedInputSchemaIsTheFieldsAsTheyAre() throws {
        let data = try Data(contentsOf: Fixture.package.appendingPathComponent("Schema/wallet.input.schema.json"))
        let schema = try XCTUnwrap(try JSONSerialization.jsonObject(with: data) as? [String: Any])
        let properties = try XCTUnwrap(schema["properties"] as? [String: [String: Any]])
        XCTAssertEqual(Set(properties.keys), Set(WalletAgent.fields.keys).union(["directory"]))
        for (field, note) in WalletAgent.fields {
            XCTAssertEqual(properties[field]?["description"] as? String, note, field)
        }
        XCTAssertEqual(properties["withdraw"]?["enum"] as? [String], WalletWithdraw.allCases.map(\.rawValue))
    }

    /// `Wallet.md` names every field, every role's words, every look role, string key, tuning key and launch state.
    func testTheReferenceListsEveryKey() throws {
        let reference = try String(contentsOf: Fixture.package.appendingPathComponent("Schema/Wallet.md"), encoding: .utf8)
        var keys = Array(WalletAgent.fields.keys)
        keys += WalletRole.allCases.flatMap { $0.properties.map(\.key) }
        keys += WalletTables.look.map(\.key) + WalletTables.strings.map(\.key) + WalletTables.tuning.map(\.key) + WalletTables.launch.map(\.name)
        for key in keys { XCTAssertTrue(reference.contains("| `\(key)` |"), "Wallet.md lists \(key)") }
    }

    /// The answer the repository ships for the Seer call is the one the Seer call answers, its paths relative to the
    /// project. `WALLET_EXAMPLES=1` writes it again.
    func testTheShippedSeerAnswerIsTheSeerCallsAnswer() async throws {
        let folder = try Fixture.folder()
        let call = try Data(contentsOf: Fixture.package.appendingPathComponent("Schema/examples/seer.json"))
        let answer = try await AnyAgentPackage(WalletAgent.self).perform(call, host: AgentHost(directory: folder.path))
        let relative = String(decoding: answer, as: UTF8.self)
            .replacingOccurrences(of: folder.path.replacingOccurrences(of: "/", with: "\\/") + "\\/", with: "")
            .replacingOccurrences(of: folder.path + "/", with: "")
        let object = try JSONSerialization.jsonObject(with: Data(relative.utf8))
        let shipped = Fixture.package.appendingPathComponent("Schema/examples/seer.answer.json")
        if ProcessInfo.processInfo.environment["WALLET_EXAMPLES"] == "1" {
            let pretty = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes])
            try (String(decoding: pretty, as: UTF8.self) + "\n").write(to: shipped, atomically: true, encoding: .utf8)
        }
        let expected = try JSONSerialization.jsonObject(with: Data(contentsOf: shipped))
        XCTAssertEqual(object as? NSDictionary, expected as? NSDictionary, "Schema/examples/seer.answer.json is the Seer call's answer")
        XCTAssertFalse(relative.contains(folder.path), "no absolute path")
    }
}
