//  WHAT: The template of `WalletWithdrawSheet.swift`: the withdrawal in four steps, written with `withdraw: on`, and
//        with `soon` for a `withdraw` launch line (its Confirm then stays faded: nothing is sent).

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

    /// A withdrawal in four steps, each sliding in over the last: the bank account (a routing number of 9 digits, an
    /// account number of at least 4, checking or savings), the amount (up to what is available, with quick amounts),
    /// a review, then done. A chevron goes back a step; the close mark leaves until the last step, whose Done does.
    //@if withdraw.on
    /// Confirming hands the app's `withdraw` the account and the amount; a throw says so and stays on the review.
    //@else
    /// Withdrawals are not open yet: the review's Confirm stays faded, and nothing is sent.
    //@endif
    struct WalletWithdrawSheet: View {
        let available: Double
    //@if withdraw.on
        let withdraw: @MainActor (WalletWithdrawal) async throws -> Void
    //@endif

        private enum Step {
            case bank, amount, review, done

            /// The step the chevron goes back to.
            var back: Step? {
                switch self {
                case .amount: return .bank
                case .review: return .amount
                case .bank, .done: return nil
                }
            }
        }

        @Environment(\.dismiss) private var dismiss
        @State private var step = Step.bank
        @State private var routing = ""
        @State private var account = ""
        @State private var checking = true
        @State private var amountText = ""
        @FocusState private var amountFocused: Bool
    //@if withdraw.on
        @State private var sending = false
        @State private var failed = false
    //@endif

        private var amount: Double { Double(amountText) ?? 0 }
        private var bankReady: Bool { routing.count == 9 && account.count >= 4 }
        private var amountReady: Bool { amount > 0 && amount <= available }
        private var kind: String { checking ? WalletStrings.withdrawChecking : WalletStrings.withdrawSavings }
        private var maskedAccount: String { account.count >= 4 ? "•••• " + account.suffix(4) : account }
        private var maskedRouting: String { routing.count >= 4 ? "•••••" + routing.suffix(4) : routing }

        var body: some View {
            NavigationStack {
                ZStack {
                    switch step {
                    case .bank:
                        bankStep
                            .transition(.asymmetric(insertion: .move(edge: .leading), removal: .move(edge: .leading).combined(with: .opacity)))
                    case .amount:
                        amountStep
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .opacity)))
                    case .review:
                        reviewStep
                            .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading).combined(with: .opacity)))
                    case .done:
                        doneStep
                            .transition(.opacity.combined(with: .scale(scale: 0.96)))
                    }
                }
                .animation({{withdrawAnimation}}, value: step)
                .modifier(WalletSheetBar(title: title))
                .toolbar {
                    #if os(iOS)
                    ToolbarItem(placement: .topBarTrailing) { closeItem }
                    ToolbarItem(placement: .topBarLeading) { backItem }
                    #else
                    ToolbarItem(placement: .primaryAction) { closeItem }
                    ToolbarItem(placement: .navigation) { backItem }
                    #endif
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationBackground(.{{material}})
        }

        private var title: String {
            switch step {
            case .bank: return WalletStrings.withdrawBankTitle
            case .amount: return WalletStrings.withdrawTitle
            case .review: return WalletStrings.withdrawReviewTitle
            case .done: return WalletStrings.withdrawDoneTitle
            }
        }

        @ViewBuilder private var closeItem: some View {
            if step != .done {
                WalletCloseButton { dismiss() }
            }
        }

        @ViewBuilder private var backItem: some View {
            if let back = step.back {
                Button {
                    withAnimation { step = back }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .light))
                }
                .accessibilityLabel(WalletStrings.withdrawBack)
            }
        }

        // MARK: The bank account

        private var bankStep: some View {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 8) {
                    Image(systemName: "{{bankSymbol}}")
                        .font(.system(size: 44, weight: .thin))
                        .foregroundStyle(WalletLook.secondaryForeground.opacity(0.6))
                        .padding(.bottom, 12)
                        .accessibilityHidden(true)
                    Text(WalletStrings.withdrawBank)
                        .font(WalletLook.body)
                        .foregroundStyle(WalletLook.foreground.opacity(0.75))
                    Text(WalletStrings.withdrawPrivacy)
                        .font(WalletLook.note2)
                        .foregroundStyle(WalletLook.foreground.opacity(0.6))
                        .italic()
                        .multilineTextAlignment(.center)
                        .opacity(0.55)
                        .padding(.top, 2)
                }
                .padding(.bottom, 32)
                VStack(spacing: 16) {
                    field(WalletStrings.withdrawRouting, WalletStrings.withdrawRoutingPlaceholder, text: $routing, limit: 9)
                    field(WalletStrings.withdrawAccount, WalletStrings.withdrawAccountPlaceholder, text: $account, limit: 17)
                    VStack(alignment: .leading, spacing: 6) {
                        label(WalletStrings.withdrawKind)
                        HStack(spacing: 8) {
                            option(WalletStrings.withdrawChecking, checks: true)
                            option(WalletStrings.withdrawSavings, checks: false)
                        }
                    }
                }
                .padding(.horizontal, WalletLook.gutter + 8)
                Spacer()
                action(WalletStrings.withdrawContinue, enabled: bankReady) {
                    withAnimation { step = .amount }
                    amountFocused = true
                }
                .padding(.horizontal, WalletLook.gutter + 8)
                .padding(.bottom, WalletLook.gutter)
            }
        }

        private func field(_ title: String, _ placeholder: String, text: Binding<String>, limit: Int) -> some View {
            VStack(alignment: .leading, spacing: 6) {
                label(title)
                TextField(placeholder, text: text)
                    #if os(iOS)
                    .keyboardType(.numberPad)
                    .textInputAutocapitalization(.never)
                    #endif
                    .font(.system(size: 16, weight: .light, design: .{{design}}))
                    .autocorrectionDisabled()
                    .onChange(of: text.wrappedValue) { _, typed in
                        if typed.count > limit { text.wrappedValue = String(typed.prefix(limit)) }
                    }
                    .padding(.vertical, 10)
                    .overlay(alignment: .bottom) {
                        Rectangle()
                            .fill(WalletLook.foreground.opacity(0.15))
                            .frame(height: 1)
                    }
            }
        }

        private func label(_ text: String) -> some View {
            Text(text)
                .font(.system(size: {{eyebrowSize}}, weight: .medium))
                .tracking(1.5)
                .foregroundStyle(WalletLook.secondaryForeground)
        }

        private func option(_ title: String, checks: Bool) -> some View {
            let selected = checking == checks
            return Button {
                withAnimation(.easeInOut(duration: 0.18)) { checking = checks }
            } label: {
                Text(title)
                    .font(.system(size: 14, weight: selected ? .regular : .light, design: .{{design}}))
                    .foregroundStyle(selected ? WalletLook.foreground : WalletLook.secondaryForeground)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(selected ? WalletLook.secondaryBackground : Color.clear)
                            .overlay(RoundedRectangle(cornerRadius: 4).stroke(WalletLook.foreground.opacity(selected ? 0.15 : 0.08), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
            .animation(.easeInOut(duration: 0.18), value: selected)
            .accessibilityAddTraits(selected ? .isSelected : [])
        }

        // MARK: The amount

        private var amountStep: some View {
            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "{{bankSymbol}}")
                        .font(.system(size: 12, weight: .light))
                    Text("\(maskedAccount)  ·  \(kind)")
                        .font(.system(size: 13, weight: .light, design: .{{design}}))
                }
                .foregroundStyle(WalletLook.secondaryForeground)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(WalletLook.secondaryBackground.opacity(0.6))
                        .overlay(Capsule().stroke(WalletLook.foreground.opacity(0.08), lineWidth: 1))
                )
                .padding(.top, 24)
                Spacer()
                VStack(spacing: 12) {
                    WalletEyebrow(text: WalletStrings.withdrawAmount)
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text(WalletStrings.balanceUnit)
                            .font(.system(size: 20, weight: .light, design: .{{design}}))
                            .foregroundStyle(WalletLook.secondaryForeground)
                            .offset(y: -4)
                        TextField(WalletFormat.number(0), text: $amountText)
                            #if os(iOS)
                            .keyboardType(.decimalPad)
                            #endif
                            .font(.system(size: 46, weight: .light, design: .{{design}}))
                            .foregroundStyle(WalletLook.foreground)
                            .multilineTextAlignment(.center)
                            .focused($amountFocused)
                            .frame(minWidth: 120)
                            .fixedSize()
                            .onChange(of: amountText) { _, typed in
                                let kept = allowed(typed)
                                if kept != typed { amountText = kept }
                            }
                    }
                    Text(WalletStrings.withdrawAvailable(WalletFormat.amount(available)))
                        .font(.system(size: 13, weight: .regular, design: .{{design}}))
                        .foregroundStyle(amount > available ? Color.red.opacity(0.8) : WalletLook.secondaryForeground)
                    HStack(spacing: 8) {
                        quick(WalletStrings.withdrawQuarter, share: 0.25)
                        quick(WalletStrings.withdrawHalf, share: 0.5)
                        quick(WalletStrings.withdrawMax, share: 1)
                    }
                    .padding(.top, 12)
                }
                .padding(.horizontal, WalletLook.gutter)
                Spacer()
                action(WalletStrings.withdrawContinue, enabled: amountReady) {
                    withAnimation { step = .review }
                }
                .padding(.horizontal, WalletLook.gutter + 8)
                .padding(.bottom, WalletLook.gutter)
            }
        }

        private func quick(_ title: String, share: Double) -> some View {
            Button {
                amountText = WalletFormat.number(available * share)
                WalletHaptic.light()
            } label: {
                Text(title)
                    .font(.system(size: 12, weight: .regular, design: .{{design}}))
                    .foregroundStyle(WalletLook.secondaryForeground)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(WalletLook.secondaryBackground.opacity(0.7))
                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(WalletLook.foreground.opacity(0.08), lineWidth: 1))
                    )
            }
            .buttonStyle(.plain)
        }

        /// What was typed, kept to digits and one point, with no more decimals than an amount is written with.
        private func allowed(_ typed: String) -> String {
            let parts = typed.filter { $0.isNumber || $0 == "." }.components(separatedBy: ".")
            guard parts.count > 1 else { return parts[0] }
            let format = WalletStrings.balanceNumber
            var decimals = 6
            if let point = format.firstIndex(of: ".") {
                decimals = Int(format[format.index(after: point)...].prefix(while: \.isNumber)) ?? 0
            }
            return decimals == 0 ? parts[0] : parts[0] + "." + parts[1].prefix(decimals)
        }

        // MARK: The review

        private var reviewStep: some View {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 24) {
                    VStack(spacing: 8) {
                        WalletEyebrow(text: WalletStrings.withdrawReviewAmount)
                        Text(WalletFormat.amount(amount))
                            .font(.system(size: 38, weight: .light, design: .{{design}}))
                            .foregroundStyle(WalletLook.foreground)
                            .contentTransition(.numericText())
                    }
                    .padding(.bottom, 12)
                    VStack(spacing: 0) {
                        WalletDetailRow(label: WalletStrings.withdrawReviewTo, value: "\(maskedAccount)  ·  \(kind)")
                        Divider().padding(.horizontal, 16)
                        WalletDetailRow(label: WalletStrings.withdrawReviewRouting, value: maskedRouting)
                        Divider().padding(.horizontal, 16)
                        WalletDetailRow(label: WalletStrings.withdrawReviewArrival, value: WalletStrings.withdrawReviewArrives)
                    }
                    .modifier(WalletCardStyle())
    //@if withdraw.on
                    if failed {
                        Text(WalletStrings.withdrawFailed)
                            .font(WalletLook.note2)
                            .foregroundStyle(Color.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
    //@endif
                }
                .padding(.horizontal, WalletLook.gutter)
                Spacer()
    //@if withdraw.on
                action(WalletStrings.withdrawConfirm, enabled: !sending, loading: sending) {
                    Task { await send() }
                }
    //@else
                action(WalletStrings.withdrawConfirm, enabled: false) {}
    //@endif
                .padding(.horizontal, WalletLook.gutter + 8)
                .padding(.bottom, WalletLook.gutter)
            }
        }
    //@if withdraw.on

        private func send() async {
            sending = true
            failed = false
            WalletHaptic.medium()
            do {
                try await withdraw(WalletWithdrawal(routingNumber: routing, accountNumber: account, checking: checking, amount: amount))
                withAnimation { step = .done }
                WalletHaptic.light()
            } catch {
                failed = true
            }
            sending = false
        }
    //@endif

        // MARK: Done

        private var doneStep: some View {
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .fill(WalletLook.positive.opacity(0.1))
                            .frame(width: 80, height: 80)
                        Circle()
                            .stroke(WalletLook.positive.opacity(0.2), lineWidth: 1)
                            .frame(width: 80, height: 80)
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .thin))
                            .foregroundStyle(WalletLook.positive)
                    }
                    .padding(.bottom, 12)
                    .accessibilityHidden(true)
                    Text(WalletStrings.withdrawDoneHeading)
                        .font(WalletLook.body)
                        .foregroundStyle(WalletLook.foreground.opacity(0.75))
                    VStack(spacing: 8) {
                        Text("\(WalletFormat.amount(amount))  ·  \(maskedAccount)")
                            .font(WalletLook.note2)
                            .foregroundStyle(WalletLook.foreground.opacity(0.6))
                            .opacity(0.7)
                        Text(WalletStrings.withdrawDoneNote)
                            .font(WalletLook.note2)
                            .foregroundStyle(WalletLook.foreground.opacity(0.6))
                            .italic()
                            .opacity(0.45)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 2)
                }
                .padding(.horizontal, WalletLook.gutter)
                Spacer()
                action(WalletStrings.withdrawDone, enabled: true) { dismiss() }
                    .padding(.horizontal, WalletLook.gutter + 8)
                    .padding(.bottom, WalletLook.gutter)
            }
        }

        // MARK: The outlined button every step ends with

        private func action(_ title: String, enabled: Bool, loading: Bool = false, run: @escaping @MainActor () -> Void) -> some View {
            Button {
                guard enabled, !loading else { return }
                run()
                WalletHaptic.light()
            } label: {
                ZStack {
                    if loading {
                        ProgressView()
                            .scaleEffect(0.85)
                    } else {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold, design: .{{design}}))
                    }
                }
                .modifier(WalletOutlined(enabled: enabled && !loading))
            }
            .disabled(!enabled || loading)
            .animation(.easeInOut(duration: 0.15), value: enabled)
            .animation(.easeInOut(duration: 0.15), value: loading)
        }
    }

    #Preview {
    //@if withdraw.on
        WalletWithdrawSheet(available: 28.05, withdraw: { _ in })
    //@else
        WalletWithdrawSheet(available: 28.05)
    //@endif
    }
    """##
}
