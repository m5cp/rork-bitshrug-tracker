import SwiftUI

struct ProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showNotificationSettings: Bool = false
    @State private var showAbout: Bool = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 6) {
                        Text("BitShrug")
                            .font(.system(.title3, design: .monospaced, weight: .bold))
                        Text("Bitcoin Market Context")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .listRowBackground(Color.clear)
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
                    Text("All indicators, scores, and labels are for informational and educational purposes only. Always do your own research.")
                }

                Section {
                    Label {
                        Text("No Personal Data Collected")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        Text("No Tracking or Analytics")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "eye.slash.fill")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Privacy")
                }

                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("CoinGecko")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Price, market cap, volume, history")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "network")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Alternative.me")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Fear & Greed Index")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "heart.text.square")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Calculated Locally")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("MVRV, Puell, Power Law, Rainbow, Cycles")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "function")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Data Sources")
                }

                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refresh")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("On launch and pull-to-refresh")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Accuracy")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Estimates from price data, not live blockchain")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    } icon: {
                        Image(systemName: "info.circle")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("How It Works")
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

                    Button {
                        showAbout = true
                    } label: {
                        Label {
                            Text("About BitShrug")
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
                    Label {
                        Text("Terms of Use")
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "doc.text")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        Text("Privacy Policy")
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "hand.raised.fill")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        Text("Accessibility")
                            .font(.subheadline)
                    } icon: {
                        Image(systemName: "accessibility")
                            .foregroundStyle(.secondary)
                    }
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
    }
}
