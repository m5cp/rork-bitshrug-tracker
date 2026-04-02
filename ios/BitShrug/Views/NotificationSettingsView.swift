import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager = NotificationManager.shared

    var body: some View {
        NavigationStack {
            List {
                if !manager.isAuthorized {
                    permissionSection
                }

                Section {
                    alertToggle(
                        icon: "globe",
                        title: "Environment Change",
                        description: "When market environment shifts between Bullish, Neutral, and Bearish",
                        isOn: $manager.environmentAlerts
                    )

                    alertToggle(
                        icon: "gauge.medium",
                        title: "Signal Strength",
                        description: "When signal strength moves significantly",
                        isOn: $manager.signalStrengthAlerts
                    )

                    alertToggle(
                        icon: "waveform.path.ecg",
                        title: "Indicator Change",
                        description: "When Momentum, Trend, or Sentiment shifts direction",
                        isOn: $manager.indicatorAlerts
                    )
                } header: {
                    Text("Alerts")
                } footer: {
                    Text("Maximum 1–2 notifications per day. No spam.")
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        exampleRow("Environment shifted to Risk Elevated")
                        exampleRow("Momentum turning bullish")
                        exampleRow("Signal Strength increased to 62")
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Example Notifications")
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .onChange(of: manager.environmentAlerts) { _, newValue in
                if newValue { ensurePermission() }
            }
            .onChange(of: manager.signalStrengthAlerts) { _, newValue in
                if newValue { ensurePermission() }
            }
            .onChange(of: manager.indicatorAlerts) { _, newValue in
                if newValue { ensurePermission() }
            }
        }
    }

    private var permissionSection: some View {
        Section {
            VStack(spacing: 12) {
                Image(systemName: "bell.badge")
                    .font(.system(size: 32))
                    .foregroundStyle(.orange)

                Text("Enable Notifications")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("Allow BitShrug to notify you when market conditions change.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Button {
                    Task { await manager.requestPermission() }
                } label: {
                    Text("Allow Notifications")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.borderedProminent)
                .tint(.orange)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .listRowBackground(Color.clear)
        }
    }

    private func alertToggle(icon: String, title: String, description: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Label {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.orange)
            }
        }
        .tint(.orange)
    }

    private func exampleRow(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "bell.fill")
                .font(.caption)
                .foregroundStyle(.tertiary)
            Text(text)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private func ensurePermission() {
        if !manager.isAuthorized {
            Task { await manager.requestPermission() }
        }
    }
}
