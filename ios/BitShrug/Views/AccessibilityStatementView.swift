import SwiftUI

struct AccessibilityStatementView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Accessibility")
                            .font(.title2)
                            .fontWeight(.heavy)

                        Text("Last updated: April 2, 2026")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    sectionBlock(
                        title: "Our Commitment",
                        content: "Fog of Bitcoin is committed to making the app accessible to everyone, including people with disabilities. We strive to meet the Web Content Accessibility Guidelines (WCAG) 2.1 Level AA standards as applicable to mobile applications."
                    )

                    sectionBlock(
                        title: "Accessibility Features",
                        content: "Fog of Bitcoin supports the following accessibility features:\n\n\u{2022} Dynamic Type \u{2014} All text scales with your preferred text size in iOS Settings\n\u{2022} VoiceOver \u{2014} All interactive elements, charts, and indicators include descriptive accessibility labels\n\u{2022} Dark Mode \u{2014} The app is designed with a dark theme that provides high contrast for readability\n\u{2022} Reduce Motion \u{2014} Animations respect the iOS Reduce Motion setting\n\u{2022} Color Accessibility \u{2014} Status indicators use both color and text labels so information is never conveyed by color alone\n\u{2022} Semantic Colors \u{2014} The app uses system semantic colors that adapt to accessibility settings"
                    )

                    sectionBlock(
                        title: "Navigation",
                        content: "The app uses standard iOS navigation patterns including tab bars, navigation stacks, and sheets. All interactive elements meet the minimum 44x44 point touch target size recommended by Apple's Human Interface Guidelines."
                    )

                    sectionBlock(
                        title: "Known Limitations",
                        content: "Some chart visualizations (Power Law corridor, price charts, Rainbow Chart) convey information visually that may not be fully accessible to screen reader users. We provide text-based alternatives for all chart data through surrounding labels and descriptions."
                    )

                    sectionBlock(
                        title: "Feedback",
                        content: "We welcome feedback about the accessibility of Fog of Bitcoin. If you encounter accessibility barriers or have suggestions for improvement, please contact us through the App Store listing. We take accessibility feedback seriously and will work to address any issues."
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
