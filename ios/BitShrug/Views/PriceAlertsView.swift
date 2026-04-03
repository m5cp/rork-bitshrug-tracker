import SwiftUI

struct PriceAlertsView: View {
    @Environment(\.dismiss) private var dismiss
    let viewModel: BitcoinViewModel
    @State private var alertManager = PriceAlertManager.shared
    @State private var newTargetText: String = ""
    @State private var showAddTarget: Bool = false

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
                        showAddTarget = true
                    } label: {
                        Label("Add Price Target", systemImage: "plus.circle.fill")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                } header: {
                    Text("Custom Targets")
                } footer: {
                    if alertManager.customTargets.isEmpty {
                        Text("Set custom price targets to get notified when Bitcoin reaches specific levels.")
                    }
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
                Text("Enter a USD price target. You'll be notified when Bitcoin crosses this level.")
            }
        }
    }

    private func targetIcon(_ target: Double) -> String {
        viewModel.price < target ? "arrow.up.circle.fill" : "arrow.down.circle.fill"
    }
}
