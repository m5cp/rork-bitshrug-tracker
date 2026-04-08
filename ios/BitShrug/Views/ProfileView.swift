import SwiftUI
import ActivityKit

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showNotificationSettings: Bool = false
    @State private var showAbout: Bool = false
    @State private var showPrivacyPolicy: Bool = false
    @State private var showTermsOfUse: Bool = false
    @State private var showEULA: Bool = false
    @State private var showAccessibility: Bool = false
    @State private var showDisclaimer: Bool = false
    @State private var showPriceAlerts: Bool = false
    @State private var showPaywall: Bool = false
    @State private var showSubscription: Bool = false
    @State private var premium = PremiumManager.shared
    @State private var isRestoringPurchases: Bool = false
    @AppStorage("appColorScheme") private var appColorScheme: String = "dark"
    @AppStorage("liveActivityEnabled") private var liveActivityEnabled: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 10) {
                        ShrugBadge(size: .large, style: .hero)
                            .padding(.top, 4)

                        Text("Fog of Bitcoin")
                            .font(.system(.title3, design: .monospaced, weight: .bold))

                        Text("Understanding Bitcoin")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(
                        LinearGradient(
                            colors: [.orange.opacity(0.06), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .listRowSeparator(.hidden)
                    .padding(.vertical, 8)
                }

                Section {
                    Label {
                        Text("Educational Purpose Only")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "graduationcap.fill")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        Text("Not Financial Advice")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        Text("Past Performance \u{2260} Future Results")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Important")
                } footer: {
                    Text("All indicators, scores, and labels are for educational purposes only. This app does not recommend any action. Always do your own research.")
                }

                Section {
                    NavigationLink {
                        DataSourcesDetailView()
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("View Data Sources")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Finnhub, CryptoCompare, Alternative.me, Network Stats API")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        } icon: {
                            Image(systemName: "server.rack")
                                .foregroundStyle(.orange)
                        }
                    }
                } header: {
                    Text("Data Sources")
                }

                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Not Real-Time")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Prices and indicators are delayed estimates, not live data")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Not Financial Advice")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Do not make financial decisions based on this app")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Calculated Locally")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Indicators estimated from price data, not live network data")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "function")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("How It Works")
                } footer: {
                    Text("Numbers shown are not live. Nobody should view this as financial advice or make financial decisions based on this app. For educational purposes only.")
                }

                Section {
                    Button {
                        showSubscription = true
                    } label: {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(premium.isPremium ? "Fog of Bitcoin Pro" : "Upgrade to Pro")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text(premium.isPremium ? "You're supporting Fog of Bitcoin" : "Unlock all features")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        } icon: {
                            Image(systemName: premium.isPremium ? "crown.fill" : "star.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(.primary)

                    if premium.isPremium {
                        Button {
                            premium.openManageSubscriptions()
                        } label: {
                            Label {
                                Text("Manage Subscription")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            } icon: {
                                Image(systemName: "creditcard.fill")
                                    .foregroundStyle(.orange)
                            }
                        }
                        .foregroundStyle(.primary)
                    }

                    Button {
                        isRestoringPurchases = true
                        Task {
                            await premium.restore()
                            isRestoringPurchases = false
                        }
                    } label: {
                        Label {
                            HStack {
                                Text("Restore Purchases")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                if isRestoringPurchases {
                                    Spacer()
                                    ProgressView()
                                        .scaleEffect(0.8)
                                }
                            }
                        } icon: {
                            Image(systemName: "arrow.clockwise.circle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(.primary)
                    .disabled(isRestoringPurchases)
                } header: {
                    Text("Subscription")
                }

                Section {
                    Button {
                        showNotificationSettings = true
                    } label: {
                        Label {
                            Text("Notifications")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "bell.badge")
                                .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(.primary)

                    Picker(selection: $appColorScheme) {
                        Text("Dark").tag("dark")
                        Text("Light").tag("light")
                        Text("System").tag("system")
                    } label: {
                        Label {
                            Text("Appearance")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "circle.lefthalf.filled")
                                .foregroundStyle(.orange)
                        }
                    }

                    Toggle(isOn: $liveActivityEnabled) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Live Activity")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Show price and score on Lock Screen")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                        } icon: {
                            Image(systemName: "sparkles.rectangle.stack")
                                .foregroundStyle(.orange)
                        }
                    }
                    .tint(.orange)
                    .onChange(of: liveActivityEnabled) { _, enabled in
                        if enabled {
                            LiveActivityManager.shared.start(
                                price: 0,
                                change24h: 0,
                                score: 0,
                                label: "Loading"
                            )
                        } else {
                            LiveActivityManager.shared.end()
                        }
                    }

                    Button {
                        showAbout = true
                    } label: {
                        Label {
                            Text("About Fog of Bitcoin")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        } icon: {
                            Image(systemName: "info.circle")
                                .foregroundStyle(.orange)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Settings")
                }

                Section {
                    Button {
                        showDisclaimer = true
                    } label: {
                        Label {
                            Text("Disclaimer & Risks")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "exclamationmark.shield.fill")
                                .foregroundStyle(.red)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Label {
                            Text("Privacy Policy")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showTermsOfUse = true
                    } label: {
                        Label {
                            Text("Terms of Use")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "doc.text")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showEULA = true
                    } label: {
                        Label {
                            Text("Apple Licensed Application EULA")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "apple.logo")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)

                    Button {
                        showAccessibility = true
                    } label: {
                        Label {
                            Text("Accessibility")
                                .font(.subheadline)
                        } icon: {
                            Image(systemName: "accessibility")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                } header: {
                    Text("Legal")
                }
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(isPresented: $showNotificationSettings) {
            NotificationSettingsView()
        }
        .sheet(isPresented: $showAbout) {
            AboutView()
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
        .sheet(isPresented: $showTermsOfUse) {
            TermsOfUseView()
        }
        .sheet(isPresented: $showEULA) {
            EULAView()
        }
        .sheet(isPresented: $showAccessibility) {
            AccessibilityStatementView()
        }
        .sheet(isPresented: $showDisclaimer) {
            DisclaimerRisksView()
        }
        .sheet(isPresented: $showSubscription) {
            SubscriptionView()
        }
    }
}
