import SwiftUI
import RevenueCat

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var premium = PremiumManager.shared
    @State private var selectedPackageID: String?
    @State private var appeared: Bool = false
    @State private var selectedPlan: PlanTier = .pro
    @State private var showTerms: Bool = false
    @State private var showPrivacy: Bool = false

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 560 : .infinity }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color(.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.top, 56)
                        .padding(.bottom, 28)

                    planToggle
                        .padding(.bottom, 24)

                    comparisonTable
                        .padding(.bottom, 28)

                    if premium.isLoading {
                        ProgressView()
                            .tint(.orange)
                            .padding(.vertical, 32)
                    } else if let current = premium.offerings?.current {
                        purchaseSection(current)
                            .padding(.bottom, 24)
                    }

                    testimonialCard
                        .padding(.bottom, 24)

                    legalSection
                        .padding(.bottom, 32)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isRegular ? 40 : 20)
            }
            .scrollIndicators(.hidden)

            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.secondary)
                    .frame(width: 30, height: 30)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            .padding(.top, 14)
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
        .sheet(isPresented: $showTerms) {
            TermsOfUseView()
        }
        .sheet(isPresented: $showPrivacy) {
            PrivacyPolicyView()
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                appeared = true
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.15), .orange.opacity(0.02)],
                            center: .center,
                            startRadius: 20,
                            endRadius: 70
                        )
                    )
                    .frame(width: 100, height: 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.orange, .yellow],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .symbolEffect(.bounce, options: .nonRepeating)
            }
            .opacity(appeared ? 1 : 0)
            .scaleEffect(appeared ? 1 : 0.8)

            VStack(spacing: 6) {
                Text("TouchGrass BTC Pro")
                    .font(.system(size: isRegular ? 34 : 30, weight: .bold))

                Text("The complete Bitcoin macro toolkit")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
            .opacity(appeared ? 1 : 0)
            .offset(y: appeared ? 0 : 10)
        }
    }

    // MARK: - Plan Toggle

    private var planToggle: some View {
        HStack(spacing: 0) {
            ForEach(PlanTier.allCases, id: \.self) { tier in
                Button {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedPlan = tier
                    }
                } label: {
                    Text(tier.label)
                        .font(.system(.subheadline, weight: .semibold))
                        .foregroundStyle(selectedPlan == tier ? .white : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            selectedPlan == tier
                                ? AnyShapeStyle(.orange)
                                : AnyShapeStyle(.clear)
                        )
                        .clipShape(.rect(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(3)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 12))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
    }

    // MARK: - Comparison Table

    private var comparisonTable: some View {
        VStack(spacing: 0) {
            comparisonHeader

            ForEach(Array(FeatureRow.allFeatures.enumerated()), id: \.element.id) { index, feature in
                comparisonRow(feature, isLast: index == FeatureRow.allFeatures.count - 1)
            }
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 16)
    }

    private func sortedPackages(_ packages: [Package]) -> [Package] {
        let order: [PackageType] = [.annual, .monthly, .weekly]
        return packages.sorted { a, b in
            let ai = order.firstIndex(of: a.packageType) ?? 99
            let bi = order.firstIndex(of: b.packageType) ?? 99
            return ai < bi
        }
    }

    private var comparisonHeader: some View {
        HStack(spacing: 0) {
            Text("Features")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("Free")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.secondary)
                .textCase(.uppercase)
                .tracking(0.5)
                .frame(width: 56)

            Text("Pro")
                .font(.system(size: 11, weight: .bold))
                .foregroundStyle(.orange)
                .textCase(.uppercase)
                .tracking(0.5)
                .frame(width: 56)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.tertiarySystemBackground).opacity(0.5))
    }

    private func comparisonRow(_ feature: FeatureRow, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(feature.name)
                        .font(.subheadline)
                        .foregroundStyle(.primary)

                    if let detail = feature.detail {
                        Text(detail)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                featureStatus(feature.free)
                    .frame(width: 56)

                featureStatus(feature.pro)
                    .frame(width: 56)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 11)

            if !isLast {
                Divider()
                    .padding(.leading, 16)
            }
        }
    }

    @ViewBuilder
    private func featureStatus(_ status: FeatureAccess) -> some View {
        switch status {
        case .full:
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 16))
                .foregroundStyle(.green)
        case .limited(let text):
            Text(text)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color(.tertiarySystemFill))
                .clipShape(.capsule)
        case .none:
            Image(systemName: "minus")
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.quaternary)
        }
    }

    // MARK: - Purchase Section

    private func purchaseSection(_ offering: Offering) -> some View {
        VStack(spacing: 12) {
            let sorted = sortedPackages(offering.availablePackages)
            ForEach(sorted, id: \.identifier) { package in
                purchaseCard(package, offering: offering)
            }
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private func purchaseCard(_ package: Package, offering: Offering) -> some View {
        let isYearly = package.packageType == .annual
        let isLifetime = package.packageType == .lifetime
        let isSelected = selectedPackageID == package.identifier

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPackageID = package.identifier
            }
            Task { await premium.purchase(package: package) }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 3) {
                        HStack(spacing: 8) {
                            Text(planTitle(for: package))
                                .font(.system(.body, weight: .semibold))
                                .foregroundStyle(isLifetime ? .white : .primary)

                            if isYearly {
                                Text("BEST VALUE")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(.orange)
                                    .clipShape(.capsule)
                            }

                            if isLifetime {
                                Text("ONE TIME")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(.white.opacity(0.9))
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(.white.opacity(0.2))
                                    .clipShape(.capsule)
                            }
                        }

                        Text(planSubtitle(for: package))
                            .font(.caption)
                            .foregroundStyle(isLifetime ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.tertiary))
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.system(.title3, weight: .bold))
                            .foregroundStyle(isLifetime ? AnyShapeStyle(.white) : AnyShapeStyle(isYearly ? .orange : .primary))

                        Text(planPeriod(for: package))
                            .font(.caption2)
                            .foregroundStyle(isLifetime ? AnyShapeStyle(.white.opacity(0.7)) : AnyShapeStyle(.tertiary))
                    }
                }
                .padding(16)

                if isYearly {
                    savingsBar(for: package, in: offering)
                }
            }
            .background(
                Group {
                    if isLifetime {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(
                                LinearGradient(
                                    colors: [Color.orange, Color.orange.opacity(0.85)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(isYearly ? Color.orange.opacity(0.04) : Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        isYearly ? Color.orange.opacity(0.3) : Color.clear,
                                        lineWidth: isYearly ? 1.5 : 0
                                    )
                            )
                    }
                }
            )
            .foregroundStyle(.primary)
            .scaleEffect(isSelected && premium.isPurchasing ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(premium.isPurchasing)
        .sensoryFeedback(.selection, trigger: selectedPackageID)
    }

    private func savingsBar(for package: Package, in offering: Offering) -> some View {
        let weeklyPkg = offering.availablePackages.first { $0.packageType == .weekly }
        let monthlyPkg = offering.availablePackages.first { $0.packageType == .monthly }

        let savingsText: String = {
            if let weeklyPrice = weeklyPkg?.storeProduct.price as? NSDecimalNumber {
                let yearlyTotal = package.storeProduct.price as NSDecimalNumber
                let weeklyAnnual = weeklyPrice.doubleValue * 52.0
                let perWeek = yearlyTotal.doubleValue / 52.0
                if weeklyAnnual > 0 {
                    let pct = Int(((weeklyAnnual - yearlyTotal.doubleValue) / weeklyAnnual * 100).rounded())
                    return "Just $\(String(format: "%.2f", perWeek))/week \u{00B7} Save \(pct)%"
                }
            }
            if let monthlyPrice = monthlyPkg?.storeProduct.price as? NSDecimalNumber {
                let yearlyTotal = package.storeProduct.price as NSDecimalNumber
                let monthlyAnnual = monthlyPrice.doubleValue * 12.0
                let savings = monthlyAnnual - yearlyTotal.doubleValue
                if savings > 0, monthlyAnnual > 0 {
                    let pct = Int((savings / monthlyAnnual * 100).rounded())
                    return "Save \(pct)% vs. monthly"
                }
            }
            return "Best value \u{2014} less than $1/week"
        }()

        return HStack(spacing: 6) {
            Image(systemName: "tag.fill")
                .font(.system(size: 10))
            Text(savingsText)
                .font(.system(size: 11, weight: .semibold))
        }
        .foregroundStyle(.orange)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.06))
        .clipShape(.rect(bottomLeadingRadius: 14, bottomTrailingRadius: 14))
    }

    // MARK: - Testimonial

    private var testimonialCard: some View {
        VStack(spacing: 12) {
            HStack(spacing: 2) {
                ForEach(0..<5) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 11))
                        .foregroundStyle(.orange)
                }
            }

            Text("\"Finally an app that explains Bitcoin without the hype. The environment score keeps me grounded.\"")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .italic()
                .lineSpacing(2)

            Text("No predictions. No hype. Just clarity.")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(.tertiary)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appeared ? 1 : 0)
    }

    // MARK: - Legal

    private var legalSection: some View {
        VStack(spacing: 10) {
            Text("Your subscription keeps TouchGrass BTC independent,\nad-free, and continuously improving.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscriptions automatically renew unless canceled at least 24 hours before the end of the current period. You can manage and cancel subscriptions in your Apple ID account settings. Free trial automatically converts to a paid subscription unless canceled before the trial ends.")
                .font(.system(size: 10))
                .foregroundStyle(.quaternary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 4)

            HStack(spacing: 16) {
                Button("Restore Purchases") {
                    Task { await premium.restore() }
                }
                .font(.caption)
                .foregroundStyle(.secondary)

                Text("\u{00B7}")
                    .foregroundStyle(.quaternary)

                Button("Terms") { showTerms = true }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Text("\u{00B7}")
                    .foregroundStyle(.quaternary)

                Button("Privacy") { showPrivacy = true }
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    // MARK: - Helpers

    private func planTitle(for package: Package) -> String {
        switch package.packageType {
        case .weekly: return "Weekly"
        case .monthly: return "Monthly"
        case .annual: return "Yearly"
        case .lifetime: return "Lifetime"
        default: return package.storeProduct.localizedTitle
        }
    }

    private func planSubtitle(for package: Package) -> String {
        switch package.packageType {
        case .weekly: return "Cancel anytime"
        case .monthly: return "Cancel anytime"
        case .annual: return "3-day free trial \u{00B7} Billed yearly"
        case .lifetime: return "Pay once, keep forever"
        default: return ""
        }
    }

    private func planPeriod(for package: Package) -> String {
        switch package.packageType {
        case .weekly: return "per week"
        case .monthly: return "per month"
        case .annual: return "per year"
        case .lifetime: return "forever"
        default: return ""
        }
    }
}

// MARK: - Supporting Types

private enum PlanTier: CaseIterable {
    case free, pro

    var label: String {
        switch self {
        case .free: return "Free"
        case .pro: return "Pro"
        }
    }
}

nonisolated enum FeatureAccess: Sendable {
    case full
    case limited(String)
    case none
}

struct FeatureRow: Identifiable {
    let id: String
    let name: String
    let detail: String?
    let free: FeatureAccess
    let pro: FeatureAccess

    static let allFeatures: [FeatureRow] = [
        FeatureRow(id: "score", name: "Environment Score", detail: "Real-time macro gauge", free: .full, pro: .full),
        FeatureRow(id: "price", name: "Live Price & Chart", detail: "Interactive with EMA overlay", free: .full, pro: .full),
        FeatureRow(id: "indicators", name: "On-Chain Indicators", detail: nil, free: .limited("3"), pro: .full),
        FeatureRow(id: "powerlaw", name: "Power Law & Rainbow", detail: "Corridor & band charts", free: .full, pro: .full),
        FeatureRow(id: "cycle", name: "Halving Cycle Tracker", detail: nil, free: .full, pro: .full),
        FeatureRow(id: "learn", name: "Learn Library", detail: "Full education content", free: .full, pro: .full),
        FeatureRow(id: "insights", name: "Daily Insights", detail: "What changed & why", free: .none, pro: .full),
        FeatureRow(id: "weekly", name: "Weekly Summary", detail: "Direction & narrative", free: .none, pro: .full),
        FeatureRow(id: "notifications", name: "Smart Notifications", detail: "Environment shifts & alerts", free: .none, pro: .full),
        FeatureRow(id: "alerts", name: "Custom Price Alerts", detail: "Set any price level", free: .none, pro: .full),
        FeatureRow(id: "briefing", name: "Daily Briefing", detail: "Morning macro recap", free: .none, pro: .full),
    ]
}
