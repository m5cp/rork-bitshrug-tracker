import SwiftUI

struct TermsOfUseView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Terms of Use")
                            .font(.title2)
                            .fontWeight(.heavy)

                        Text("Last updated: April 2, 2026")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    sectionBlock(
                        title: "Acceptance of Terms",
                        content: "By downloading, installing, or using TouchGrass BTC (\"the App\"), you agree to be bound by these Terms of Use. If you do not agree to these terms, do not use the App."
                    )

                    sectionBlock(
                        title: "Description of Service",
                        content: "TouchGrass BTC is an educational application designed to help users understand Bitcoin market conditions, historical patterns, and mathematical models. The App displays delayed market data, calculated indicators, and educational content. TouchGrass BTC is NOT a financial advisory service, brokerage, exchange, or trading platform."
                    )

                    sectionBlock(
                        title: "No Financial Advice",
                        content: "Nothing in this App constitutes financial advice, investment advice, trading advice, or any other form of professional advice. The App does not recommend purchasing, selling, holding, or trading Bitcoin or any other cryptocurrency. All information is provided for educational and informational purposes only. You should consult a qualified financial advisor before making any investment decisions."
                    )

                    sectionBlock(
                        title: "Assumption of Risk",
                        content: "Bitcoin and cryptocurrencies are extremely volatile and speculative assets. You could lose all of your money. By using this App, you acknowledge and accept that:\n\n\u{2022} Cryptocurrency values can fluctuate dramatically, including to zero\n\u{2022} Past performance does not guarantee future results\n\u{2022} Historical patterns may not repeat\n\u{2022} The App's indicators, scores, and models are educational tools, not predictions\n\u{2022} You are solely responsible for your own financial decisions"
                    )

                    sectionBlock(
                        title: "Data Accuracy",
                        content: "The App displays delayed market data obtained from third-party sources. Prices and indicators are not real-time. Calculated indicators are mathematical estimates that may differ from values reported by professional analytics platforms. TouchGrass BTC makes no warranty regarding the accuracy, completeness, or timeliness of any data displayed."
                    )

                    sectionBlock(
                        title: "In-App Purchases",
                        content: "Premium features are available through auto-renewable subscriptions processed by Apple. Payment is charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. You can manage and cancel subscriptions in your Apple ID account settings."
                    )

                    sectionBlock(
                        title: "Intellectual Property",
                        content: "All content, design, and code in TouchGrass BTC are the intellectual property of the developer. You may not copy, modify, distribute, or reverse-engineer the App or its contents."
                    )

                    sectionBlock(
                        title: "Limitation of Liability",
                        content: "To the maximum extent permitted by applicable law, TouchGrass BTC and its developers shall not be liable for any direct, indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, or other intangible losses, resulting from your use of or inability to use the App, or any decisions made based on information provided by the App."
                    )

                    sectionBlock(
                        title: "Modifications",
                        content: "We reserve the right to modify these Terms of Use at any time. Continued use of the App after changes constitutes acceptance of the modified terms."
                    )

                    sectionBlock(
                        title: "Governing Law",
                        content: "These Terms of Use are governed by the laws of the United States. Any disputes arising from these terms or your use of the App shall be resolved in accordance with applicable law."
                    )

                    sectionBlock(
                        title: "Contact",
                        content: "If you have questions about these Terms of Use, please contact us through the App Store listing."
                    )
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
