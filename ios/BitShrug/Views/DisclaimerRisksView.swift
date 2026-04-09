import SwiftUI

struct DisclaimerRisksView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Disclaimer & Risks")
                            .font(.title2)
                            .fontWeight(.heavy)

                        Text("Last updated: April 2, 2026")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    sectionBlock(
                        title: "Not Financial Advice",
                        content: "Fog of Bitcoin is an educational tool designed to help users understand Bitcoin market conditions. It is NOT a financial advisory service. Fog of Bitcoin does not provide financial advice, investment advice, trading advice, or any other kind of professional advice. Nothing in this app should be construed as a recommendation to purchase, sell, hold, or trade Bitcoin or any other cryptocurrency."
                    )

                    sectionBlock(
                        title: "No Recommendation to Purchase",
                        content: "Fog of Bitcoin does not recommend purchasing Bitcoin or any cryptocurrency. The information presented — including scores, indicators, charts, and commentary — is purely educational and intended to help users understand historical patterns and market concepts. Any decision to purchase, sell, or hold any asset is solely your own responsibility."
                    )

                    sectionBlock(
                        title: "Risk of Loss",
                        content: "Bitcoin and all cryptocurrencies are extremely volatile assets. You could lose all of your money. The value of Bitcoin can and does fluctuate dramatically, including dropping to zero. Past performance is not indicative of future results. Historical patterns shown in this app may not repeat. There is no guarantee that any trend, cycle, or model will continue."
                    )

                    sectionBlock(
                        title: "Data Accuracy",
                        content: "Prices and indicators shown in Fog of Bitcoin are delayed estimates — not real-time market data. Numbers are not live. Indicators are calculated locally from historical price data using mathematical models and estimates. They may differ significantly from values reported by professional on-chain analytics platforms. Do not rely on these numbers for any financial decision."
                    )

                    sectionBlock(
                        title: "Educational Purpose Only",
                        content: "This app exists solely to help users learn about and understand Bitcoin as a technology and asset class. It presents historical observations, mathematical models, and market concepts for educational purposes. The \"Environment Score,\" cycle phases, Power Law corridor, and all other features are learning tools — not trading signals."
                    )

                    sectionBlock(
                        title: "No Guarantee",
                        content: "Fog of Bitcoin makes no guarantees about the accuracy, completeness, or timeliness of any information provided. The developers of Fog of Bitcoin are not responsible for any losses, damages, or costs arising from the use of this app or reliance on any information contained within it."
                    )

                    sectionBlock(
                        title: "Your Responsibility",
                        content: "You are solely responsible for your own financial decisions. Always conduct your own research. Consult a qualified financial advisor before making any investment decisions. Never invest more than you can afford to lose entirely."
                    )

                    HStack(spacing: 8) {
                        ShrugBadge(size: .small, style: .inline)
                        Text("Where signal meets uncertainty.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .italic()
                    }
                    .padding(.top, 8)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
        }
    }

    private func sectionBlock(title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.heavy)
                .foregroundStyle(.primary)

            Text(content)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
