import SwiftUI

struct DataSourcesDetailView: View {
    var body: some View {
        List {
            Section {
                Text("Prices and indicators shown in BitShrug are delayed estimates — not real-time data. Do not make financial decisions based on this app.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
            }

            Section {
                sourceRow(
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange,
                    name: "Finnhub",
                    detail: "BTC price and 24h change",
                    url: "finnhub.io"
                )

                sourceRow(
                    icon: "chart.bar.xaxis",
                    color: .blue,
                    name: "CryptoCompare",
                    detail: "Market cap, volume, supply, 365-day price history, 200-Week MA calculation",
                    url: "cryptocompare.com"
                )

                sourceRow(
                    icon: "heart.text.square",
                    color: .green,
                    name: "Alternative.me",
                    detail: "Fear & Greed Index",
                    url: "alternative.me"
                )

                sourceRow(
                    icon: "cube.transparent",
                    color: .purple,
                    name: "Network Stats API",
                    detail: "Hash rate, block height",
                    url: "blockchain.info"
                )
            } header: {
                Text("Live Data Sources")
            } footer: {
                Text("Data is fetched on app launch and pull-to-refresh. Prices are not live streaming.")
            }

            Section {
                calculatedRow(name: "Environment Score", detail: "Trend + Momentum + Positioning + Volatility")
                calculatedRow(name: "200-Day EMA", detail: "Calculated from 365-day price history")
                calculatedRow(name: "200-Week MA", detail: "Calculated from 1,400 days of price history")
                calculatedRow(name: "MVRV Z-Score", detail: "Estimated from log regression model")
                calculatedRow(name: "Puell Multiple", detail: "Current vs average daily miner revenue")
                calculatedRow(name: "Stock-to-Flow", detail: "Supply / annual flow ratio")
                calculatedRow(name: "Supply in Profit", detail: "Estimated from MVRV Z-Score")
                calculatedRow(name: "Power Law / Rainbow", detail: "Log regression corridor from genesis date")
                calculatedRow(name: "4-Year Cycle Phase", detail: "Time since halving + price drawdown from cycle high")
            } header: {
                Text("Calculated Locally")
            } footer: {
                Text("These indicators are mathematical estimates based on price data — not sourced from live network data or on-chain analytics platforms.")
            }

            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Not Real-Time")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "clock.badge.exclamationmark")
                            .foregroundStyle(.red)
                    }
                    Text("All numbers are delayed estimates. Do not treat them as live market data.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)

                VStack(alignment: .leading, spacing: 8) {
                    Label {
                        Text("Not Financial Advice")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    } icon: {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.red)
                    }
                    Text("BitShrug is for educational and informational purposes only. Nobody should trade or make financial decisions based on this app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            } header: {
                Text("Disclaimer")
            }
        }
        .navigationTitle("Data Sources")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func sourceRow(icon: String, color: Color, name: String, detail: String, url: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 3) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(url)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundStyle(.tertiary)
            }
        } icon: {
            Image(systemName: icon)
                .foregroundStyle(color)
        }
        .padding(.vertical, 2)
    }

    private func calculatedRow(name: String, detail: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        } icon: {
            Image(systemName: "function")
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 1)
    }
}
