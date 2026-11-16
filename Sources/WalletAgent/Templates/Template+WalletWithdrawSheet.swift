//  WHAT: The template of `WalletWithdrawSheet.swift`, written with `withdraw: on`.

extension Template {
    static let walletWithdrawSheet = ##"""
    import SwiftUI

    /// What the person asked to withdraw: the account it goes to, and how much.
    struct WalletWithdrawal: Equatable, Sendable {
        var routingNumber: String
        var accountNumber: String
        var checking: Bool
        var amount: Double
    }

    /// A withdrawal: the bank account, an amount up to what is available, then the app's `withdraw`, then done.
    struct WalletWithdrawSheet: View {
        let available: Double
        let withdraw: @MainActor (WalletWithdrawal) async throws -> Void

        @Environment(\.dismiss) private var dismiss
        @State private var routing = ""
        @State private var account = ""
        @State private var checking = true
        @State private var amountText = ""
        @State private var sending = false
        @State private var failed = false
        @State private var done = false

        private var amount: Double { Double(amountText) ?? 0 }

        private var ready: Bool {
            routing.count == 9 && routing.allSatisfy(\.isNumber) && account.count >= 4 && account.allSatisfy(\.isNumber)
                && amount > 0 && amount <= available && !sending
        }

        var body: some View {
            NavigationStack {
                ScrollView {
                    if done {
                        finished
                    } else {
                        form
                    }
                }
                .modifier(WalletSheetBar(title: WalletStrings.withdrawTitle, close: { dismiss() }))
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.{{material}})
        }

        private var form: some View {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Image(systemName: "{{bankSymbol}}")
                        .font(.system(size: 44, weight: .ultraLight))
                        .foregroundStyle(WalletLook.secondaryForeground)
                        .accessibilityHidden(true)
                    Text(WalletStrings.withdrawBank)
                        .font(WalletLook.heading)
                        .foregroundStyle(WalletLook.foreground.opacity(0.75))
                    Text(WalletStrings.withdrawPrivacy)
                        .font(WalletLook.note2)
                        .italic()
                        .multilineTextAlignment(.center)
                        .foregroundStyle(WalletLook.secondaryForeground)
                }
                field(WalletStrings.withdrawRouting, WalletStrings.withdrawRoutingPlaceholder, text: $routing)
                field(WalletStrings.withdrawAccount, WalletStrings.withdrawAccountPlaceholder, text: $account)
                VStack(alignment: .leading, spacing: 8) {
                    label(WalletStrings.withdrawKind)
                    HStack(spacing: 12) {
                        kind(WalletStrings.withdrawChecking, selected: checking) { checking = true }
                        kind(WalletStrings.withdrawSavings, selected: !checking) { checking = false }
                    }
                }
                VStack(spacing: 8) {
                    WalletEyebrow(text: WalletStrings.withdrawAmount)
                    TextField(WalletFormat.number(0), text: $amountText)
                        .font(.system(size: {{balanceSize}}, weight: .light, design: .{{design}}))
                        .multilineTextAlignment(.center)
                        #if os(iOS)
                        .keyboardType(.decimalPad)
                        #endif
                    HStack(spacing: 12) {
                        Text(WalletStrings.withdrawAvailable(WalletFormat.amount(available)))
                            .foregroundStyle(WalletLook.secondaryForeground)
                        Button(WalletStrings.withdrawMax) {
                            WalletHaptic.light()
                            amountText = WalletFormat.number(available)
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(WalletLook.accent)
                    }
                    .font(WalletLook.note2)
                }
                if failed {
                    Text(WalletStrings.withdrawFailed)
                        .font(WalletLook.note2)
                        .foregroundStyle(Color.red.opacity(0.85))
                        .multilineTextAlignment(.center)
                }
                outlined(WalletStrings.withdrawConfirm, enabled: ready) {
                    Task { await send() }
                }
            }
            .padding(.horizontal, WalletLook.gutter)
            .padding(.vertical, 24)
        }

        private var finished: some View {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle")
                    .font(.system(size: 44, weight: .ultraLight))
                    .foregroundStyle(WalletLook.positive)
                    .accessibilityHidden(true)
                Text(WalletStrings.withdrawDoneTitle)
                    .font(WalletLook.heading)
                    .foregroundStyle(WalletLook.foreground.opacity(0.75))
                Text(WalletStrings.withdrawDoneNote)
                    .font(WalletLook.note2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(WalletLook.secondaryForeground)
                outlined(WalletStrings.withdrawDone, enabled: true) { dismiss() }
                    .padding(.top, 16)
            }
            .padding(.horizontal, WalletLook.gutter)
            .padding(.vertical, 48)
        }

        private func field(_ title: String, _ placeholder: String, text: Binding<String>) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                label(title)
                TextField(placeholder, text: text)
                    .font(.system(size: 16, design: .{{design}}))
                    .autocorrectionDisabled()
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    #endif
                    .padding(.vertical, 12)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(WalletLook.foreground.opacity(0.2))
                            .frame(height: 1)
                    }
            }
        }

        private func label(_ text: String) -> some View {
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(WalletLook.secondaryForeground)
        }

        private func kind(_ title: String, selected: Bool, action: @escaping @MainActor () -> Void) -> some View {
            Button {
                WalletHaptic.light()
                action()
            } label: {
                Text(title)
                    .font(.system(size: 16, design: .{{design}}))
                    .foregroundStyle(WalletLook.foreground.opacity(selected ? 1 : 0.5))
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(selected ? WalletLook.secondaryBackground.opacity({{cardOpacity}}) : Color.clear)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(WalletLook.foreground.opacity(selected ? 0.3 : 0.1), lineWidth: 1))
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityAddTraits(selected ? .isSelected : [])
        }

        private func outlined(_ title: String, enabled: Bool, action: @escaping @MainActor () -> Void) -> some View {
            Button {
                WalletHaptic.light()
                action()
            } label: {
                ZStack {
                    if sending {
                        ProgressView()
                            .scaleEffect(0.85)
                    } else {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold, design: .{{design}}))
                    }
                }
                .foregroundStyle(WalletLook.foreground.opacity(enabled ? 1 : 0.3))
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(WalletLook.foreground.opacity(enabled ? 1 : 0.3), lineWidth: 1))
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .disabled(!enabled)
        }

        private func send() async {
            sending = true
            failed = false
            do {
                try await withdraw(WalletWithdrawal(routingNumber: routing, accountNumber: account, checking: checking, amount: amount))
                done = true
            } catch {
                failed = true
            }
            sending = false
        }
    }

    #Preview {
        WalletWithdrawSheet(available: 28.05, withdraw: { _ in })
    }
    """##
}
