import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
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

                    if premium.isLoading {
                        ProgressView()
                            .padding(.bottom, 32)
                    } else if let current = premium.offerings?.current {
                        packagesSection(current)
                            .padding(.bottom, 32)
                    }

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
        .alert("Error", isPresented: .init(
            get: { premium.error != nil },
            set: { if !$0 { premium.error = nil } }
        )) {
            Button("OK") { premium.error = nil }
        } message: {
            Text(premium.error ?? "")
        }
        .onChange(of: premium.isPremium) { _, isPremium in
            if isPremium { dismiss() }
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
            featureRow(name: "All Indicators", free: true, pro: true, isLast: false)
            featureRow(name: "Power Law & Cycle", free: true, pro: true, isLast: false)
            featureRow(name: "Daily Insights", free: true, pro: true, isLast: false)
            featureRow(name: "Weekly Summary", free: true, pro: true, isLast: false)
            featureRow(name: "Smart Notifications", free: true, pro: true, isLast: false)
            featureRow(name: "Support Development", free: false, pro: true, isLast: true)
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

    private func packagesSection(_ offering: Offering) -> some View {
        VStack(spacing: 10) {
            ForEach(offering.availablePackages, id: \.identifier) { package in
                packageCard(package)
            }
        }
    }

    private func packageCard(_ package: Package) -> some View {
        Button {
            Task { await premium.purchase(package: package) }
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(package.storeProduct.localizedTitle)
                        .font(.system(.body, weight: .semibold))
                        .foregroundStyle(.primary)

                    Text(package.storeProduct.localizedPriceString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if premium.isPurchasing {
                    ProgressView()
                        .tint(.orange)
                } else {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.orange)
                }
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(.rect(cornerRadius: 14))
        }
        .buttonStyle(.plain)
        .disabled(premium.isPurchasing)
    }

    private var tagline: some View {
        Text("No predictions. No hype. Just clarity.")
            .font(.footnote)
            .foregroundStyle(.tertiary)
    }

    private var legalLinks: some View {
        HStack(spacing: 16) {
            Button("Restore Purchases") {
                Task { await premium.restore() }
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
