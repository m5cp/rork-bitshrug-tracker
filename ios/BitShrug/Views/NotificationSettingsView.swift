import SwiftUI

struct NotificationSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var manager = NotificationManager.shared
    @State private var premium = PremiumManager.shared
    @State private var showPaywall: Bool = false

    private let briefingHours: [Int] = [6, 7, 8, 9, 10]

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
                    Text("Maximum 1\u{2013}2 notifications per day. No spam.")
                }

                Section {
                    if premium.isPremium {
                        Toggle(isOn: $manager.dailyBriefingEnabled) {
                            Label {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Daily Briefing")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    Text("Morning summary with score, price, and trend")
                                        .font(.caption)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(.secondary)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                            } icon: {
                                Image(systemName: "sun.and.horizon.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        .tint(.orange)
                        .onChange(of: manager.dailyBriefingEnabled) { _, newValue in
                            if newValue { ensurePermission() }
                        }

                        if manager.dailyBriefingEnabled {
                            Picker(selection: $manager.briefingHour) {
                                ForEach(briefingHours, id: \.self) { hour in
                                    Text(formatHour(hour)).tag(hour)
                                }
                            } label: {
                                Label {
                                    Text("Delivery Time")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                } icon: {
                                    Image(systemName: "clock")
                                        .foregroundStyle(.orange)
                                }
                            }
                        }
                    } else {
                        Button {
                            showPaywall = true
                        } label: {
                            HStack {
                                Label {
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack(spacing: 6) {
                                            Text("Daily Briefing")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                            premiumBadge
                                        }
                                        Text("Morning summary with score, price, and trend")
                                            .font(.caption)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.secondary)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }
                                } icon: {
                                    Image(systemName: "sun.and.horizon.fill")
                                        .foregroundStyle(.orange)
                                }

                                Spacer()

                                Image(systemName: "lock.fill")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                        .foregroundStyle(.primary)
                    }
                } header: {
                    Text("Daily Briefing")
                } footer: {
                    if premium.isPremium && manager.dailyBriefingEnabled {
                        Text("You will receive a daily notification at your chosen time with your Environment Score, Bitcoin price, and market trend.")
                    } else if !premium.isPremium {
                        Text("Unlock daily briefing notifications with TouchGrass BTC Pro.")
                    }
                }

                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        exampleRow("Environment shifted to Risk Elevated")
                        exampleRow("Momentum turning bullish")
                        exampleRow("Signal Strength increased to 62")
                        if premium.isPremium {
                            Divider()
                            dailyBriefingExample
                        }
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

    private var dailyBriefingExample: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: "sun.and.horizon.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
                Text("TouchGrass BTC Daily Briefing")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.primary)
            }
            Text("Score: 72 (+3) | BTC $84,200 | Trend: Bullish")
                .font(.system(.caption, design: .monospaced, weight: .semibold))
                .foregroundStyle(.secondary)
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

                Text("Allow TouchGrass BTC to notify you when market conditions change.")
                    .font(.caption)
                    .fontWeight(.semibold)
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
                        .fontWeight(.semibold)
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
                .fontWeight(.semibold)
                .foregroundStyle(.secondary)
        }
    }

    private func formatHour(_ hour: Int) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        var components = DateComponents()
        components.hour = hour
        components.minute = 0
        let date = Calendar.current.date(from: components) ?? Date()
        return formatter.string(from: date)
    }

    private func ensurePermission() {
        if !manager.isAuthorized {
            Task { await manager.requestPermission() }
        }
    }
}
