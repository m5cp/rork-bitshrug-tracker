import SwiftUI

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedPlan: Plan = .yearly
    @State private var premium = PremiumManager.shared

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 520 : .infinity }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.top, 60)
                        .padding(.bottom, 36)

                    featureComparison
                        .padding(.bottom, 36)

                    plans
                        .padding(.bottom, 32)

                    ctaButton
                        .padding(.bottom, 14)

                    tagline
                        .padding(.bottom, 28)

                    legalLinks
                        .padding(.bottom, 16)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isRegular ? 40 : 24)
            }
            .scrollIndicators(.hidden)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.top, 12)
            .padding(.trailing, 16)
            .accessibilityLabel("Close")
        }
    }

    private var header: some View {
        VStack(spacing: 14) {
            Image(systemName: "bitcoinsign.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)
                .symbolEffect(.pulse, options: .repeating.speed(0.3))
                .padding(.bottom, 4)

            Text("See the full\npicture")
                .font(.system(size: isRegular ? 36 : 32, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text("Unlock every indicator, daily insights,\nand the complete macro toolkit")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var featureComparison: some View {
        VStack(spacing: 0) {
            HStack {
                Text("")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("Free")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 50)
                Text("Pro")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 50)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 10)

            featureRow(name: "Environment Score", free: true, pro: true, isLast: false)
            featureRow(name: "Price & Chart", free: true, pro: true, isLast: false)
            featureRow(name: "3 Core Indicators", free: true, pro: true, isLast: false)
            featureRow(name: "All 6+ Indicators", free: false, pro: true, isLast: false)
            featureRow(name: "Daily Insights", free: false, pro: true, isLast: false)
            featureRow(name: "Weekly Summary", free: false, pro: true, isLast: false)
            featureRow(name: "Smart Notifications", free: false, pro: true, isLast: false)
            featureRow(name: "Power Law Charts", free: false, pro: true, isLast: true)
        }
        .padding(.vertical, 14)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func featureRow(name: String, free: Bool, pro: Bool, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Image(systemName: free ? "checkmark" : "xmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(free ? .secondary : Color(.quaternaryLabel))
                    .frame(width: 50)

                Image(systemName: "checkmark")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                    .frame(width: 50)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .padding(.horizontal, 16)
            }
        }
    }

    private var plans: some View {
        VStack(spacing: 10) {
            planCard(
                plan: .yearly,
                label: "$39 / year",
                detail: "$3.25/mo \u{2014} Save 46%",
                badge: "Best Value"
            )

            planCard(
                plan: .monthly,
                label: "$5.99 / month",
                detail: nil,
                badge: nil
            )
        }
    }

    private func planCard(plan: Plan, label: String, detail: String?, badge: String?) -> some View {
        Button {
            withAnimation(.spring(duration: 0.25)) {
                selectedPlan = plan
            }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 8) {
                        Text(label)
                            .font(.system(.body, weight: .semibold))
                            .foregroundStyle(.primary)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.orange)
                                .clipShape(Capsule())
                        }
                    }

                    if let detail {
                        Text(detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Image(systemName: selectedPlan == plan ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundStyle(selectedPlan == plan ? .orange : Color(.tertiaryLabel))
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(
                        selectedPlan == plan ? .orange : .clear,
                        lineWidth: 1.5
                    )
            )
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: selectedPlan)
        .accessibilityLabel("\(label)\(badge != nil ? ", \(badge!)" : "")")
    }

    private var ctaButton: some View {
        Button {
            premium.unlock()
            premium.markPaywallSeen()
            dismiss()
        } label: {
            Text("Start 7-Day Free Trial")
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.orange)
                .clipShape(.rect(cornerRadius: 14))
        }
        .sensoryFeedback(.success, trigger: premium.isPremium)
        .accessibilityLabel("Start free trial")
    }

    private var tagline: some View {
        Text("No predictions. No hype. Just clarity.")
            .font(.footnote)
            .foregroundStyle(.tertiary)
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Button("Restore Purchases") {
                premium.unlock()
            }
            .font(.caption)
            .foregroundStyle(.secondary)

            Text("\u{00B7}")
                .foregroundStyle(.quaternary)

            Button("Terms") {}
                .font(.caption)
                .foregroundStyle(.secondary)

            Text("\u{00B7}")
                .foregroundStyle(.quaternary)

            Button("Privacy") {}
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

private enum Plan {
    case monthly
    case yearly
}
