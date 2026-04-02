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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Educational Purpose Only")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("BitShrug is a learning tool that explores historical Bitcoin models and theories. It does not provide financial, investment, tax, or legal advice.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "graduationcap.fill")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Not Financial Advice")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Nothing in this app constitutes a recommendation to buy, sell, or hold any asset. All indicators, scores, and labels are for informational and educational purposes only. Always do your own research and consult a licensed financial advisor before making investment decisions.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Guarantees")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Past performance does not guarantee future results. Models like Power Law, Rainbow Chart, and cycle theory are historical observations — not predictions. Markets can behave differently than historical patterns suggest.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "chart.line.downtrend.xyaxis")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Important Disclaimers")
                }

                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Personal Data Collected")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("BitShrug does not collect, store, or share any personal financial data. No trading or account access is required.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "lock.shield.fill")
                            .foregroundStyle(.orange)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("No Tracking")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("No hidden tracking or third-party analytics. Data is used only to display market context within the app.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "eye.slash.fill")
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text("Privacy")
                }

                Section {
                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Price & Market Data")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("CoinGecko free API — price, market cap, volume, and 365-day historical data.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "network")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Fear & Greed Index")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Alternative.me — a composite index of market sentiment based on volatility, volume, social media, and surveys.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "heart.text.square")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Calculated Indicators")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("MVRV Z-Score, Puell Multiple, Power Law, Rainbow Chart, and cycle phases are calculated locally using mathematical models based on publicly available research. These are approximations, not exact on-chain metrics.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Refresh Frequency")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Data loads when you open the app and when you pull to refresh. There is no automatic background refresh. CoinGecko's free API may have a short delay from real-time prices.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundStyle(.secondary)
                    }

                    Label {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Accuracy")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Some indicators (MVRV, Supply in Profit) use mathematical estimates rather than live blockchain data. Values are approximate and intended for educational context, not precision trading.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Notifications")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("Environment, signal, and indicator alerts")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
                            VStack(alignment: .leading, spacing: 4) {
                                Text("About BitShrug")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                Text("How the Environment Score works")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
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
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Accessibility")
                                .font(.subheadline)
                            Text("BitShrug supports Dynamic Type, VoiceOver, and system accessibility settings.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    } icon: {
                        Image(systemName: "accessibility")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Legal")
                }

                Section {
                    Text("BitShrug is not affiliated with, endorsed by, or connected to Bitcoin, CoinGecko, or any financial institution. All trademarks belong to their respective owners.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
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
