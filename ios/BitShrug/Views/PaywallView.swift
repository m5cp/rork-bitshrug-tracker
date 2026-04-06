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

    private var isRegular: Bool { sizeClass == .regular }
    private var contentMaxWidth: CGFloat { isRegular ? 520 : .infinity }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            LinearGradient(
                colors: [Color(.systemBackground), Color.orange.opacity(0.03)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    heroHeader
                        .padding(.top, 56)
                        .padding(.bottom, 32)

                    freeSection
                        .padding(.bottom, 24)

                    proValueCard
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
            withAnimation(.easeOut(duration: 0.6).delay(0.1)) {
                appearAnimated = true
            }
        }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(.orange.opacity(0.1))
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(.orange.opacity(0.06))
                    .frame(width: 110, height: 110)

                Image(systemName: "bitcoinsign.circle.fill")
                    .font(.system(size: 52))
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse, options: .repeating.speed(0.3))
            }
            .padding(.bottom, 4)

            Text("Upgrade to Pro")
                .font(.system(size: isRegular ? 34 : 30, weight: .bold))
                .foregroundStyle(.primary)

            Text("Support BitShrug and get the\ncomplete experience")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 12)
    }

    // MARK: - Free Section

    private var freeSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                Text("FREE FOREVER")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.secondary)
                    .tracking(0.8)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 12)

            VStack(spacing: 0) {
                freeFeatureRow(icon: "gauge.with.dots.needle.33percent", text: "Environment Score & breakdown", isLast: false)
                freeFeatureRow(icon: "chart.xyaxis.line", text: "Live price & interactive chart", isLast: false)
                freeFeatureRow(icon: "waveform.path.ecg", text: "All indicators & on-chain data", isLast: false)
                freeFeatureRow(icon: "arrow.triangle.2.circlepath", text: "Power Law corridor & Rainbow Chart", isLast: false)
                freeFeatureRow(icon: "clock.arrow.2.circlepath", text: "Halving cycle tracker & history", isLast: false)
                freeFeatureRow(icon: "book.fill", text: "Full education & learn library", isLast: true)
            }
            .padding(.bottom, 12)
        }
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 16)
    }

    private func freeFeatureRow(icon: String, text: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .frame(width: 22)

                Text(text)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.secondary)
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

    // MARK: - Pro Value Card

    private var proValueCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                Image(systemName: "star.fill")
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                Text("PRO BENEFITS")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.orange)
                    .tracking(0.8)

                Spacer()

                Text("Everything in Free, plus:")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 14)

            VStack(spacing: 0) {
                proFeatureRow(
                    icon: "bell.badge.fill",
                    title: "Smart Notifications",
                    subtitle: "Environment shifts, indicator changes, daily briefings",
                    isLast: false
                )
                proFeatureRow(
                    icon: "text.badge.star",
                    title: "Daily Insights",
                    subtitle: "What changed and why — explained in plain language",
                    isLast: false
                )
                proFeatureRow(
                    icon: "calendar.badge.clock",
                    title: "Weekly Summary",
                    subtitle: "Direction, score change, and weekly narrative",
                    isLast: false
                )
                proFeatureRow(
                    icon: "target",
                    title: "Custom Price Alerts",
                    subtitle: "Set alerts for any price level",
                    isLast: false
                )
                proFeatureRow(
                    icon: "square.grid.2x2.fill",
                    title: "Home Screen Widget",
                    subtitle: "Environment Score at a glance, right on your Home Screen",
                    isLast: true
                )
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
        .offset(y: appearAnimated ? 0 : 20)
    }

    private func proFeatureRow(icon: String, title: String, subtitle: String, isLast: Bool) -> some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 14))
                    .foregroundStyle(.orange)
                    .frame(width: 22, height: 22)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineSpacing(1)
                }

                Spacer()

                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(.orange)
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

    // MARK: - Plan Cards

    private func planCards(_ offering: Offering) -> some View {
        VStack(spacing: 12) {
            Text("CHOOSE YOUR PLAN")
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(.secondary)
                .tracking(0.8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 2)

            ForEach(offering.availablePackages, id: \.identifier) { package in
                planCard(package, offering: offering)
            }
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 24)
    }

    private func planCard(_ package: Package, offering: Offering) -> some View {
        let isYearly = package.packageType == .annual
        let isLifetime = package.packageType == .lifetime
        let isSelected = selectedPackageID == package.identifier
        let isBestValue = isYearly

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedPackageID = package.identifier
            }
            Task { await premium.purchase(package: package) }
        } label: {
            VStack(spacing: 0) {
                if isLifetime {
                    launchOfferBanner
                }

                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 8) {
                            Text(planTitle(for: package))
                                .font(.system(.body, weight: .semibold))
                                .foregroundStyle(isLifetime ? .white : .primary)

                            if isBestValue {
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
                            .foregroundStyle(isLifetime ? AnyShapeStyle(.white) : AnyShapeStyle(isBestValue ? .orange : .primary))

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
                            .fill(isBestValue ? Color.orange.opacity(0.04) : Color(.secondarySystemBackground))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .strokeBorder(
                                        isBestValue ? Color.orange.opacity(0.3) : Color.clear,
                                        lineWidth: isBestValue ? 1.5 : 0
                                    )
                            )
                    }
                }
            )
            .scaleEffect(isSelected && premium.isPurchasing ? 0.98 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(premium.isPurchasing)
        .sensoryFeedback(.selection, trigger: selectedPackageID)
    }

    private var launchOfferBanner: some View {
        HStack(spacing: 6) {
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
            Text("LAUNCH SPECIAL — LIMITED TIME")
                .font(.system(size: 10, weight: .heavy))
                .tracking(0.5)
            Image(systemName: "sparkles")
                .font(.system(size: 10, weight: .bold))
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.15))
    }

    private func savingsBar(for package: Package, in offering: Offering) -> some View {
        let monthly = offering.availablePackages.first { $0.packageType == .monthly }
        let savingsText: String = {
            guard let monthlyPrice = monthly?.storeProduct.price as? NSDecimalNumber else { return "Save with yearly" }
            let yearlyTotal = package.storeProduct.price as NSDecimalNumber
            let monthlyAnnual = monthlyPrice.doubleValue * 12.0
            let savings = monthlyAnnual - yearlyTotal.doubleValue
            if savings > 0, monthlyAnnual > 0 {
                let pct = Int((savings / monthlyAnnual * 100).rounded())
                return "Save \(pct)% vs. monthly"
            }
            return "Save with yearly"
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
        case .monthly: return "Monthly"
        case .annual: return "Yearly"
        case .lifetime: return "Lifetime"
        default: return package.storeProduct.localizedTitle
        }
    }

    private func planSubtitle(for package: Package) -> String {
        switch package.packageType {
        case .monthly: return "Cancel anytime"
        case .annual: return "Billed once per year"
        case .lifetime: return "Pay once, keep forever"
        default: return ""
        }
    }

    private func planPeriod(for package: Package) -> String {
        switch package.packageType {
        case .monthly: return "per month"
        case .annual: return "per year"
        case .lifetime: return "forever"
        default: return ""
        }
    }

    // MARK: - Support Message

    private var supportMessage: some View {
        VStack(spacing: 8) {
            Text("No predictions. No hype. Just clarity.")
                .font(.footnote)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)

            Text("Your subscription keeps BitShrug independent,\nad-free, and continuously improving.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
        }
    }

    // MARK: - Legal

    private var legalLinks: some View {
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
