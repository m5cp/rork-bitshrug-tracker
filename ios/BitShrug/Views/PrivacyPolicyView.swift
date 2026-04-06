import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Privacy Policy")
                            .font(.title2)
                            .fontWeight(.heavy)

                        Text("Last updated: April 2, 2026")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    sectionBlock(
                        title: "Introduction",
                        content: "Fog of Bitcoin (\"the App\") is committed to protecting your privacy. This Privacy Policy explains what information the App collects, how it is used, and your rights regarding that information."
                    )

                    sectionBlock(
                        title: "Information We Do Not Collect",
                        content: "Fog of Bitcoin does not collect, store, or transmit any personal information. We do not collect your name, email address, phone number, location, IP address, device identifiers, or any other personally identifiable information. We do not use cookies, analytics, tracking pixels, or any third-party tracking services."
                    )

                    sectionBlock(
                        title: "Data Usage",
                        content: "The App fetches publicly available Bitcoin market data from third-party APIs (Finnhub, CryptoCompare, Alternative.me) to display educational market information. This data is fetched directly from these services to your device and is not routed through any Fog of Bitcoin servers. No user data is sent to these services beyond standard HTTP requests."
                    )

                    sectionBlock(
                        title: "Local Storage",
                        content: "The App stores your preferences (such as notification settings and onboarding completion) locally on your device using UserDefaults. This data never leaves your device and is not accessible to Fog of Bitcoin or any third party."
                    )

                    sectionBlock(
                        title: "In-App Purchases",
                        content: "Premium subscriptions are processed entirely by Apple through the App Store. Fog of Bitcoin does not have access to your payment information, Apple ID, or billing details. All subscription management is handled by Apple."
                    )

                    sectionBlock(
                        title: "Push Notifications",
                        content: "If you enable notifications, they are generated and scheduled locally on your device. No push notification tokens are sent to external servers. You can disable notifications at any time in the App settings or iOS Settings."
                    )

                    sectionBlock(
                        title: "Third-Party Services",
                        content: "The App communicates with the following third-party APIs solely to retrieve publicly available Bitcoin market data:\n\n\u{2022} Finnhub (finnhub.io) \u{2014} Bitcoin price data\n\u{2022} CryptoCompare (cryptocompare.com) \u{2014} Market data and price history\n\u{2022} Alternative.me \u{2014} Fear & Greed Index\n\nPlease refer to each service's own privacy policy for information about how they handle requests."
                    )

                    sectionBlock(
                        title: "Children's Privacy",
                        content: "The App is not directed at children under the age of 13. We do not knowingly collect any information from children."
                    )

                    sectionBlock(
                        title: "Changes to This Policy",
                        content: "We may update this Privacy Policy from time to time. Any changes will be reflected in the App with an updated date."
                    )

                    sectionBlock(
                        title: "Contact",
                        content: "If you have questions about this Privacy Policy, please contact us through the App Store listing."
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
