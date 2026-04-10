import SwiftUI
import RevenueCat

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var premium = PremiumManager.shared
    @State private var selectedPackageID: String?
    @State private var appearAnimated: Bool = false
    @State private var showTerms: Bool = false
    @State private var showPrivacy: Bool = false

    var triggerScore: Int?
    var triggerLabel: String?

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 520 : .infinity }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [Color(.systemBackground), Color.orange.opacity(0.04)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    tensionHeader
                        .padding(.top, 20)
                        .padding(.bottom, 28)

                    blurredPreview
                        .padding(.bottom, 28)

                    outcomeValue
                        .padding(.bottom, 28)

                    if premium.isLoading {
                        ProgressView()
                            .tint(.orange)
                            .padding(.vertical, 40)
                    } else if let current = premium.offerings?.current {
                        planCards(current)
                            .padding(.bottom, 24)
                    }

                    supportMessage
                        .padding(.bottom, 24)

                    legalLinks
                        .padding(.bottom, 20)
                }
                .frame(maxWidth: contentMaxWidth)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, isRegular ? 40 : 20)
            }
            .scrollIndicators(.hidden)
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
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appearAnimated = true
            }
        }
    }

    private var tensionHeader: some View {
        VStack(spacing: 18) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.08))
                    .frame(width: 110, height: 110)

                Circle()
                    .fill(.orange.opacity(0.04))
                    .frame(width: 140, height: 140)

                if let score = triggerScore {
                    ZStack {
                        Circle()
                            .trim(from: 0, to: Double(score) / 100.0)
                            .stroke(
                                AngularGradient(
                                    colors: [.orange.opacity(0.4), .orange],
                                    center: .center,
                                    startAngle: .degrees(-90),
                                    endAngle: .degrees(-90 + 360 * Double(score) / 100.0)
                                ),
                                style: StrokeStyle(lineWidth: 6, lineCap: .round)
                            )
                            .frame(width: 88, height: 88)
                            .rotationEffect(.degrees(-90))

                        Text("\(score)")
                            .font(.system(size: 36, weight: .heavy, design: .monospaced))
                            .foregroundStyle(.primary)
                    }
                } else {
                    Image(systemName: "lock.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.orange)
                        .symbolEffect(.pulse, options: .repeating.speed(0.3))
                }
            }
            .padding(.bottom, 4)

            if let score = triggerScore {
                VStack(spacing: 8) {
                    Text("Your Environment Score is \(score)")
                        .font(.system(size: isRegular ? 28 : 24, weight: .heavy))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("Unlock to see exactly what's driving it")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 8) {
                    Text("Know What's Really\nHappening with Bitcoin")
                        .font(.system(size: isRegular ? 28 : 24, weight: .heavy))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text("Full breakdown, insights, and alerts")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 12)
    }

    private var blurredPreview: some View {
        VStack(spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 11))
                    .foregroundStyle(.orange)
                Text("WHAT YOU'RE MISSING")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(.orange)
                    .tracking(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)

            VStack(spacing: 0) {
                blurredRow(icon: "gauge.with.dots.needle.bottom.50percent", title: "Score Breakdown", detail: "See which drivers are bullish, bearish, or neutral", isLast: false)
                blurredRow(icon: "sparkle", title: "Daily Insights", detail: "What changed today and why — in plain language", isLast: false)
                blurredRow(icon: "chart.line.uptrend.xyaxis", title: "Full Indicator Access", detail: "Puell, S2F, Supply in Profit, and more", isLast: false)
                blurredRow(icon: "calendar.badge.clock", title: "Weekly Summary", detail: "Direction, score change, and narrative", isLast: false)
                blurredRow(icon: "chart.bar.fill", title: "Progress Tracking", detail: "Score history charts over time", isLast: false)
                blurredRow(icon: "bell.badge.fill", title: "Smart Alerts", detail: "Environment shifts, price targets, daily briefings", isLast: true)
            }
            .padding(.bottom, 12)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.orange.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
                )
        )
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 16)
    }

    private func blurredRow(icon: String, title: String, detail: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                    .frame(width: 22)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)

                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "lock.fill")
                    .font(.system(size: 10))
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)

            if !isLast {
                Divider()
                    .padding(.leading, 50)
                    .padding(.trailing, 16)
            }
        }
    }

    private var outcomeValue: some View {
        VStack(spacing: 14) {
            Text("Don't just watch the price.\nUnderstand the environment.")
                .font(.headline)
                .fontWeight(.heavy)
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            Text("Know exactly what's holding Bitcoin back — or pushing it forward — after every session.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 20)
    }

    private func planCards(_ offering: Offering) -> some View {
        VStack(spacing: 12) {
            Text("CHOOSE YOUR PLAN")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            let sorted = sortedPackages(offering.availablePackages)
            ForEach(sorted, id: \.identifier) { package in
                planCard(package, offering: offering)
            }
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 24)
    }

    private func sortedPackages(_ packages: [Package]) -> [Package] {
        let order: [PackageType] = [.annual, .monthly, .weekly]
        return packages.sorted { a, b in
            let ai = order.firstIndex(of: a.packageType) ?? 99
            let bi = order.firstIndex(of: b.packageType) ?? 99
            return ai < bi
        }
    }

    private func planCard(_ package: Package, offering: Offering) -> some View {
        let isYearly = package.packageType == .annual
        let isWeekly = package.packageType == .weekly
        let isSelected = selectedPackageID == package.identifier
        let isBestValue = isYearly

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPackageID = package.identifier
            }
            Task { await premium.purchase(package: package) }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(planTitle(for: package))
                                .font(.system(.body, weight: .semibold))
                                .foregroundStyle(.primary)

                            if isBestValue {
                                Text("BEST VALUE")
                                    .font(.system(size: 9, weight: .heavy))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 7)
                                    .padding(.vertical, 3)
                                    .background(.orange)
                                    .clipShape(.capsule)
                            }
                        }

                        Text(planSubtitle(for: package))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(package.storeProduct.localizedPriceString)
                            .font(.system(.title3, weight: .bold))
                            .foregroundStyle(isBestValue ? .orange : .primary)

                        Text(planPeriod(for: package))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
                .padding(16)

                if isYearly {
                    savingsBar(for: package, in: offering)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(isBestValue ? Color.orange.opacity(0.04) : Color(.secondarySystemBackground))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(
                                isBestValue ? Color.orange.opacity(0.3) : Color.clear,
                                lineWidth: isBestValue ? 1.5 : 0
                            )
                    )
            )
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
                    return "Just $\(String(format: "%.2f", perWeek))/week · Save \(pct)%"
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
            return "Best value — less than $1/week"
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
        case .annual: return "3-day free trial · Billed yearly"
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

    private var supportMessage: some View {
        VStack(spacing: 8) {
            Text("No predictions. No hype. Just clarity.")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("Your subscription keeps TouchGrass BTC independent,\nad-free, and continuously improving.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    private var legalLinks: some View {
        VStack(spacing: 10) {
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
}
