//  WHAT: The template of `WalletValue.swift`: the conversions every mapped right side goes through.

extension Template {
    static let walletValue = ##"""
    import Foundation

    /// How a mapped value becomes what the wallet views show: one overload a type an app's field may have, so a
    /// conformance compiles whatever the field's type (an amount may be a Double, a Decimal or an Int; documents a
    /// count or a list that is counted; a date a Date, an ISO string or seconds).
    enum WalletValue {
        static func amount(_ value: Double) -> Double { value }
        static func amount(_ value: Double?) -> Double { value ?? 0 }
        static func amount(_ value: Float) -> Double { Double(value) }
        static func amount(_ value: Float?) -> Double { value.map { Double($0) } ?? 0 }
        static func amount(_ value: CGFloat) -> Double { Double(value) }
        static func amount(_ value: Decimal) -> Double { NSDecimalNumber(decimal: value).doubleValue }
        static func amount(_ value: Decimal?) -> Double { value.map { NSDecimalNumber(decimal: $0).doubleValue } ?? 0 }
        static func amount<T: BinaryInteger>(_ value: T) -> Double { Double(value) }
        static func amount<T: BinaryInteger>(_ value: T?) -> Double { value.map { Double($0) } ?? 0 }
        static func amount(_ value: String) -> Double { Double(value) ?? 0 }
        static func amount(_ value: String?) -> Double { value.flatMap { Double($0) } ?? 0 }

        static func count<T: BinaryInteger>(_ value: T) -> Int { Int(value) }
        static func count<T: BinaryInteger>(_ value: T?) -> Int { value.map { Int($0) } ?? 0 }
        static func count(_ value: Double) -> Int { Int(value) }
        static func count<C: Collection>(_ value: C) -> Int { value.count }
        static func count<C: Collection>(_ value: C?) -> Int { value?.count ?? 0 }

        static func text(_ value: String) -> String { value }
        static func text(_ value: String?) -> String { value ?? "" }
        static func text(_ value: Substring) -> String { String(value) }
        static func text(_ value: UUID) -> String { value.uuidString }
        static func text<T: BinaryInteger>(_ value: T) -> String { String(value) }

        static func optionalText(_ value: String) -> String? { value.isEmpty ? nil : value }
        static func optionalText(_ value: String?) -> String? { value.flatMap { $0.isEmpty ? nil : $0 } }
        static func optionalText(_ value: Substring) -> String? { value.isEmpty ? nil : String(value) }
        static func optionalText(_ value: UUID) -> String? { value.uuidString }
        static func optionalText<T: BinaryInteger>(_ value: T) -> String? { String(value) }

        static func date(_ value: Date) -> Date? { value }
        static func date(_ value: Date?) -> Date? { value }
        static func date(_ value: String) -> Date? {
            let formatter = ISO8601DateFormatter()
            if let date = formatter.date(from: value) { return date }
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: value) { return date }
            formatter.formatOptions = [.withFullDate]
            return formatter.date(from: value)
        }
        static func date(_ value: String?) -> Date? { value.flatMap { date($0) } }
        static func date(_ value: Double) -> Date? { Date(timeIntervalSince1970: value) }
        static func date(_ value: Int) -> Date? { Date(timeIntervalSince1970: TimeInterval(value)) }

        static func list<S: Sequence>(_ value: S) -> [S.Element] { Array(value) }
        static func list<S: Sequence>(_ value: S?) -> [S.Element] { value.map { Array($0) } ?? [] }
    }
    """##
}
