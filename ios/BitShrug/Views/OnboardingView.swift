import SwiftUI

struct OnboardingView: View {
    @Binding var isPresented: Bool
    @State private var currentPage: Int = 0
    @Environment(\.horizontalSizeClass) private var sizeClass

    private var isRegular: Bool { sizeClass == .regular }

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "bitcoinsign.circle.fill",
            iconColor: .orange,
            title: "Welcome to BitShrug",
            subtitle: "Understand the Bitcoin macro environment\nwithout the noise.",
            detail: nil
        ),
        OnboardingPage(
            icon: "gauge.with.dots.needle.bottom.50percent",
            iconColor: .orange,
            title: "Environment Score",
            subtitle: "A single 0\u{2013}100 score built from trend,\nmomentum, positioning, and volatility.",
            detail: "Know the conditions \u{2014} not predictions."
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            iconColor: Color(red: 0.2, green: 0.85, blue: 0.5),
            title: "Power Law & Cycle",
            subtitle: "See where price sits in the long-term\ncorridor and the 4-year halving cycle.",
            detail: "Context that helps you think in years, not days."
        ),
        OnboardingPage(
            icon: "sparkles",
            iconColor: .orange,
            title: "Daily Insights",
            subtitle: "Short, clear updates on what changed\nand what it means.",
            detail: "Open once a day. Stay grounded."
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, page in
                    pageView(page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: isRegular ? 420 : 380)

            pageIndicator
                .padding(.top, 24)

            Spacer()

            actionButton
                .padding(.horizontal, 32)
                .padding(.bottom, 48)
        }
        .background(Color(.systemBackground).ignoresSafeArea())
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 20) {
            Image(systemName: page.icon)
                .font(.system(size: 56))
                .foregroundStyle(page.iconColor)
                .padding(.bottom, 8)

            Text(page.title)
                .font(.system(size: isRegular ? 32 : 28, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.primary)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(3)

            if let detail = page.detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal, 40)
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? .orange : Color.white.opacity(0.15))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(duration: 0.3), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation(.spring(duration: 0.35)) {
                    currentPage += 1
                }
            } else {
                UserDefaults.standard.set(true, forKey: "bitshrug_onboarded")
                isPresented = false
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Continue" : "Get Started")
                .font(.system(.body, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(.orange)
                .clipShape(.rect(cornerRadius: 14))
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: currentPage)
    }
}

struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let detail: String?
}
