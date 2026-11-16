import Foundation
import XCTest
@testable import WalletAgent

/// The templates held to the catalog and the tables, so no call can write a file that reads a word, a number, a
/// look role or a requirement that does not exist, leaves a name unprefixed, or keeps a marker.
final class TemplateTests: XCTestCase {
    private var templates: [(part: KitPart, text: String)] {
        KitCatalog.parts.filter { !$0.template.isEmpty }.map { ($0, $0.template) }
    }

    /// Every way a call can set the flags.
    private var plans: [KitPlan] {
        var plans: [KitPlan] = []
        for withdraw in WalletWithdraw.allCases {
            for leads in [false, true] {
                for launched in [Set<String>(), Set(WalletTables.launch.map(\.name))] {
                    plans.append(KitPlan(withdraw: withdraw, tuning: [:], launched: launched, unitLeads: leads))
                }
            }
        }
        return plans
    }

    private func matches(_ pattern: String, in text: String, group: Int = 0) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
        return regex.matches(in: text, range: NSRange(text.startIndex..., in: text)).compactMap {
            Range($0.range(at: group), in: text).map { String(text[$0]) }
        }
    }

    func testEveryTemplateRendersWithEveryFlagAndEveryPlaceholderFilled() throws {
        for plan in plans {
            for part in plan.parts where !part.template.isEmpty {
                let rendered = try TemplateRender.render(part.template, flags: plan.flags, values: plan.values)
                XCTAssertFalse(rendered.contains("//@"), "\(part.name) keeps a marker")
                XCTAssertFalse(rendered.contains("{{"), "\(part.name) keeps a placeholder")
            }
        }
    }

    func testEveryPlaceholderIsATuningKeyAndEveryKeyIsUsed() {
        let known = Set(KitPlan(withdraw: .on, tuning: [:], launched: [], unitLeads: false).values.keys)
        var used: Set<String> = []
        for (part, text) in templates {
            for key in TemplateRender.placeholders(in: text) {
                XCTAssertTrue(known.contains(key), "\(part.name) uses {{\(key)}}, which no tuning key fills")
                used.insert(key.components(separatedBy: ".")[0])
            }
        }
        for key in WalletTables.tuning { XCTAssertTrue(used.contains(key.key), "no template uses the tuning key \(key.key)") }
    }

    func testEveryWordATemplateSaysIsAStringKeyAndEveryKeyIsSaid() {
        let members = Set(WalletTables.strings.filter { !$0.isSingular }.map(\.member)).union(["balanceNumber", "balanceUnit"])
        var said: Set<String> = []
        for (part, text) in templates {
            for member in matches(#"WalletStrings\.([a-zA-Z]+)"#, in: text, group: 1) {
                XCTAssertTrue(members.contains(member), "\(part.name) says WalletStrings.\(member), which no key declares")
                said.insert(member)
            }
        }
        for key in WalletTables.strings where !key.isSingular {
            XCTAssertTrue(said.contains(key.member), "no template says \(key.key)")
        }
        // A word a part says only with a flag is declared only with it.
        for plan in plans {
            let strings = StringsEmitter.emit([:], flags: plan.flags)
            for part in plan.parts where !part.template.isEmpty {
                let rendered = (try? TemplateRender.render(part.template, flags: plan.flags, values: plan.values)) ?? ""
                for member in Set(matches(#"WalletStrings\.([a-zA-Z]+)"#, in: rendered, group: 1)) {
                    XCTAssertTrue(strings.contains(" \(member):") || strings.contains(" \(member)("),
                                  "\(part.name) says \(member) with \(plan.flags.sorted()), which WalletStrings then leaves out")
                }
            }
        }
    }

    func testEveryLookRoleIsReadAndNoOther() {
        let roles = Set(WalletTables.look.map(\.key))
        var read: Set<String> = []
        for (part, text) in templates {
            for role in matches(#"WalletLook\.([a-zA-Z0-9]+)"#, in: text, group: 1) {
                XCTAssertTrue(roles.contains(role), "\(part.name) reads WalletLook.\(role), which is not a look role")
                read.insert(role)
            }
        }
        XCTAssertEqual(read, roles, "every look role is read somewhere")
    }

    func testEveryRequirementATemplateReadsIsInTheRoleTable() {
        let requirements = Set(WalletRole.allCases.flatMap { $0.properties.map(\.member) })
        for (part, text) in templates {
            for member in Set(matches(#"\.(wallet[A-Z][A-Za-z]*)"#, in: text, group: 1)) where !requirements.contains(member) {
                XCTFail("\(part.name) reads \(member), which no role declares")
            }
        }
    }

    func testEveryTypeAPartDeclaresIsListedForRenaming() {
        for (part, text) in templates {
            let declared = matches(#"(?m)^(?:struct|enum|final class|class) (Wallet[A-Za-z]*)"#, in: text, group: 1)
            XCTAssertEqual(Set(declared), Set(part.types), "\(part.name) declares \(declared), lists \(part.types)")
        }
        let protocols = ProtocolsEmitter.emit()
        let declared = matches(#"(?m)^(?:protocol|struct) (Wallet[A-Za-z]*)"#, in: protocols, group: 1)
        XCTAssertEqual(Set(declared), Set(KitCatalog.part("WalletProtocols")!.types))
        for name in KitCatalog.names { XCTAssertTrue(name.hasPrefix(KitCatalog.base), name) }
    }

    func testTheProtocolFileDeclaresEveryRequirementWithItsDefault() {
        let text = ProtocolsEmitter.emit()
        for role in WalletRole.allCases {
            XCTAssertTrue(text.contains("protocol \(role.protocolName("Wallet")) {"), "\(role)")
            for property in role.properties {
                XCTAssertTrue(text.contains("    var \(property.member): \(property.kind.swiftType) { get }"), property.member)
                XCTAssertTrue(text.contains("    var \(property.member): \(property.kind.swiftType) { \(property.defaultValue) }"), property.member)
            }
            XCTAssertTrue(text.contains("struct \(role.itemType("Wallet")): \(role.protocolName("Wallet")) {"), "the kit's own \(role)")
        }
        XCTAssertTrue(text.contains("associatedtype GroupValue: WalletGroupRepresentable = WalletGroupItem"))
    }

    func testTheRootOpensEveryLaunchState() throws {
        let plan = KitPlan(withdraw: .on, tuning: [:], launched: [], unitLeads: false)
        let root = try TemplateRender.render(KitCatalog.part("WalletView")!.template, flags: plan.flags, values: plan.values)
        for state in WalletTables.launch { XCTAssertTrue(root.contains("case .\(state.name):"), "the root opens \(state.name)") }
        let launch = LaunchEmitter.emit([], flags: plan.flags)
        for state in WalletTables.launch { XCTAssertTrue(launch.contains("case \(state.name)\n"), state.name) }
        XCTAssertTrue(launch.contains("static var state: State? {\n        nil\n    }"), "no line: a plain launch")
    }

    func testRenamingTouchesOnlyTheKitsNames() {
        let text = "struct WalletView {}\nlet a = WalletViewModel()\nextension Wallet: WalletRepresentable {}\nText(\"Wallet\")"
        XCTAssertEqual(TemplateRender.renaming(text, names: KitCatalog.names, base: "Wallet", prefix: "Points"),
                       "struct PointsView {}\nlet a = WalletViewModel()\nextension Wallet: PointsRepresentable {}\nText(\"Wallet\")")
    }
}
