import SwiftUI

struct EULAView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Apple Licensed Application\nEnd User License Agreement")
                            .font(.title2)
                            .fontWeight(.heavy)

                        Text("Last updated: April 2, 2026")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    sectionBlock(
                        title: "Agreement",
                        content: "This End User License Agreement (\"EULA\") is a legal agreement between you and BitShrug for the use of the BitShrug mobile application (\"Licensed Application\") available through the Apple App Store."
                    )

                    sectionBlock(
                        title: "Apple Standard EULA",
                        content: "This Licensed Application is licensed to you under the Apple Standard Licensed Application End User License Agreement (\"Standard EULA\"), which is incorporated herein by reference. The Standard EULA is available at:\n\nhttps://www.apple.com/legal/internet-services/itunes/dev/stdeula/\n\nBy downloading or using the Licensed Application, you agree to the terms of the Standard EULA as well as the additional terms below."
                    )

                    sectionBlock(
                        title: "Scope of License",
                        content: "The Licensed Application is licensed, not sold, to you. This license grants you a limited, non-exclusive, non-transferable right to use the Licensed Application on any Apple device that you own or control, as permitted by the Usage Rules set forth in the Apple Media Services Terms and Conditions."
                    )

                    sectionBlock(
                        title: "Educational Use Only",
                        content: "The Licensed Application is provided for educational and informational purposes only. It does not provide financial advice, investment advice, or trading recommendations. You acknowledge that:\n\n\u{2022} The App is not a financial advisory service\n\u{2022} No content constitutes a recommendation to act\n\u{2022} You are solely responsible for your financial decisions\n\u{2022} Bitcoin is a volatile asset and you could lose all of your money"
                    )

                    sectionBlock(
                        title: "Subscriptions",
                        content: "The Licensed Application offers auto-renewable subscriptions for premium features. Payment is charged to your Apple ID account. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. You can manage and cancel subscriptions in your Apple ID Account Settings. Any unused portion of a free trial period will be forfeited when you purchase a subscription."
                    )

                    sectionBlock(
                        title: "Maintenance and Support",
                        content: "The developer is solely responsible for providing maintenance and support services for the Licensed Application. Apple has no obligation to furnish any maintenance and support services with respect to the Licensed Application."
                    )

                    sectionBlock(
                        title: "Warranty Disclaimer",
                        content: "THE LICENSED APPLICATION IS PROVIDED \"AS IS\" WITHOUT WARRANTY OF ANY KIND. TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE DEVELOPER DISCLAIMS ALL WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT."
                    )

                    sectionBlock(
                        title: "Limitation of Liability",
                        content: "TO THE MAXIMUM EXTENT PERMITTED BY LAW, THE DEVELOPER SHALL NOT BE LIABLE FOR ANY DAMAGES ARISING FROM YOUR USE OF THE LICENSED APPLICATION, INCLUDING BUT NOT LIMITED TO FINANCIAL LOSSES RESULTING FROM DECISIONS MADE BASED ON INFORMATION DISPLAYED IN THE APP."
                    )

                    sectionBlock(
                        title: "Third-Party Terms",
                        content: "You must comply with applicable third-party terms of agreement when using the Licensed Application, including the terms of your wireless data service agreement."
                    )

                    sectionBlock(
                        title: "Contact",
                        content: "If you have questions about this EULA, please contact us through the App Store listing. For Apple-related inquiries, contact Apple at https://www.apple.com/support/."
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
