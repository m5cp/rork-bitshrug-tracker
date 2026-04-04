import SwiftUI

struct PriceAlertsView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: BitcoinViewModel
    @State private var alertManager = PriceAlertManager.shared
    @State private var premium = PremiumManager.shared
    @State private var newTargetText: String = ""
    @State private var showAddTarget: Bool = false
    @State private var showAddScoreTarget: Bool = false
    @State private var newScoreValue: String = ""
    @State private var newScoreDirection: ScoreAlertDirection = .crossesEither
    @State private var showPaywall: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Toggle(isOn: $alertManager.powerLawSupportAlert) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Power Law Support")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if viewModel.powerLawSupport > 0 {
                                    Text("Currently $\(Int(viewModel.powerLawSupport).formatted(.number))")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "arrow.down.to.line")
                                .foregroundStyle(.orange)
                        }
                    }
                    .tint(.orange)

                    Toggle(isOn: $alertManager.powerLawResistanceAlert) {
                        Label {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Power Law Resistance")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if viewModel.powerLawResistance > 0 {
                                    Text("Currently $\(Int(viewModel.powerLawResistance).formatted(.number))")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        } icon: {
                            Image(systemName: "arrow.up.to.line")
                                .foregroundStyle(.orange)
                        }
                    }
                    .tint(.orange)
                } header: {
                    Text("Power Law Alerts")
                } footer: {
                    Text("Get notified when price crosses Power Law support or resistance levels.")
                }

                Section {
                    ForEach(alertManager.customTargets, id: \.self) { target in
                        HStack {
                            Image(systemName: targetIcon(target))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(viewModel.price < target ? AppColors.bullish : AppColors.bearish)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("$\(Int(target).formatted(.number))")
                                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                                Text(viewModel.price < target ? "Price crosses above" : "Price crosses below")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            let distance = ((target - viewModel.price) / viewModel.price) * 100
                            Text(String(format: "%+.1f%%", distance))
                                .font(.system(.caption, design: .monospaced, weight: .bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .onDelete { indexSet in
                        alertManager.removeTargets(at: indexSet)
                    }

                    Button {
                        if premium.isPremium {
                            showAddTarget = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Label {
                            HStack(spacing: 6) {
                                Text("Add Price Target")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if !premium.isPremium {
                                    premiumBadge
                                }
                            }
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                } header: {
                    Text("Custom Price Targets")
                } footer: {
                    if alertManager.customTargets.isEmpty {
                        Text("Set custom price targets to get notified when Bitcoin reaches specific levels.")
                    }
                }

                Section {
                    ForEach(alertManager.scoreAlertTargets) { target in
                        HStack {
                            Image(systemName: scoreTargetIcon(target))
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(.orange)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Score \(target.direction.label.lowercased()) \(target.value)")
                                    .font(.system(.subheadline, design: .monospaced, weight: .semibold))

                                let currentScore = viewModel.environmentScore
                                let distance = target.value - currentScore
                                Text("Currently \(currentScore) (\(distance >= 0 ? "+" : "")\(distance) away)")
                                    .font(.caption)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                    }
                    .onDelete { indexSet in
                        alertManager.removeScoreTargets(at: indexSet)
                    }

                    Button {
                        if premium.isPremium {
                            showAddScoreTarget = true
                        } else {
                            showPaywall = true
                        }
                    } label: {
                        Label {
                            HStack(spacing: 6) {
                                Text("Add Score Alert")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if !premium.isPremium {
                                    premiumBadge
                                }
                            }
                        } icon: {
                            Image(systemName: "plus.circle.fill")
                        }
                    }
                } header: {
                    Text("Environment Score Alerts")
                } footer: {
                    Text("Get notified when the Environment Score crosses your target level.")
                }
            }
            .navigationTitle("Price Alerts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .alert("Add Price Target", isPresented: $showAddTarget) {
                TextField("Price in USD", text: $newTargetText)
                    .keyboardType(.numberPad)
                Button("Add") {
                    if let price = Double(newTargetText), price > 0 {
                        alertManager.addTarget(price)
                    }
                    newTargetText = ""
                }
                Button("Cancel", role: .cancel) {
                    newTargetText = ""
                }
            } message: {
                Text("Enter a USD price target. You will be notified when Bitcoin crosses this level.")
            }
            .sheet(isPresented: $showAddScoreTarget) {
                addScoreTargetSheet
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var premiumBadge: some View {
        Text("PRO")
            .font(.system(size: 8, weight: .heavy))
            .foregroundStyle(.white)
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .background(
                LinearGradient(
                    colors: [.orange, .orange.opacity(0.8)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(Capsule())
    }

    private var addScoreTargetSheet: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Text("Score")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Spacer()
                        TextField("0–100", text: $newScoreValue)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(.subheadline, design: .monospaced, weight: .semibold))
                            .frame(width: 80)
                    }

                    Picker("Direction", selection: $newScoreDirection) {
                        ForEach(ScoreAlertDirection.allCases, id: \.self) { dir in
                            Text(dir.label).tag(dir)
                        }
                    }
                    .font(.subheadline)
                    .fontWeight(.semibold)
                } header: {
                    Text("Alert Conditions")
                } footer: {
                    Text("Current Environment Score: \(viewModel.environmentScore)")
                }

                Section {
                    VStack(alignment: .leading, spacing: 8) {
                        exampleRow(icon: "arrow.up.circle.fill", color: AppColors.bullish, text: "Score crosses above 70")
                        exampleRow(icon: "arrow.down.circle.fill", color: AppColors.bearish, text: "Score drops below 35")
                        exampleRow(icon: "arrow.up.arrow.down.circle.fill", color: .orange, text: "Score crosses 50 in either direction")
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Examples")
                }
            }
            .navigationTitle("Score Alert")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newScoreValue = ""
                        newScoreDirection = .crossesEither
                        showAddScoreTarget = false
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let val = Int(newScoreValue), val >= 0, val <= 100 {
                            alertManager.addScoreTarget(ScoreAlertTarget(value: val, direction: newScoreDirection))
                        }
                        newScoreValue = ""
                        newScoreDirection = .crossesEither
                        showAddScoreTarget = false
                    }
                    .fontWeight(.semibold)
                    .disabled(Int(newScoreValue) == nil)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private func exampleRow(icon: String, color: Color, text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }

    private func targetIcon(_ target: Double) -> String {
        viewModel.price < target ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }

    private func scoreTargetIcon(_ target: ScoreAlertTarget) -> String {
        switch target.direction {
        case .crossesAbove: return "arrow.up.circle.fill"
        case .crossesBelow: return "arrow.down.circle.fill"
        case .crossesEither: return "arrow.up.arrow.down.circle.fill"
        }
    }
}
