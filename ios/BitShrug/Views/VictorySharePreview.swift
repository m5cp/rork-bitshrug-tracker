import SwiftUI

struct VictorySharePreview: View {
    let question: DailyQuestion
    let streak: Int
    let totalCorrect: Int
    let totalAnswered: Int
    let price: String
    let onShare: (UIImage) -> Void

    @State private var selectedStyle: ShareCardStyle = .dark
    @State private var showBranding: Bool = true
    @State private var showStats: Bool = true

    nonisolated enum ShareCardStyle: String, CaseIterable, Sendable {
        case dark = "Midnight"
        case ember = "Ember"
        case frost = "Frost"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    cardPreview
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    stylePicker
                        .padding(.horizontal, 20)

                    toggleOptions
                        .padding(.horizontal, 20)

                    renderShareButton
                        .padding(.horizontal, 20)
                }
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Share Your Victory")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        VictoryShareCard(
            question: question,
            streak: streak,
            totalCorrect: totalCorrect,
            totalAnswered: totalAnswered,
            price: price,
            style: selectedStyle,
            showBranding: showBranding,
            showStats: showStats
        )
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.5), radius: 24, y: 10)
    }

    // MARK: - Style Picker

    private var stylePicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("STYLE")
                .font(.system(size: 11, weight: .heavy))
                .foregroundStyle(.secondary)
                .tracking(1.2)

            HStack(spacing: 10) {
                ForEach(ShareCardStyle.allCases, id: \.rawValue) { style in
                    Button {
                        withAnimation(.spring(duration: 0.3)) {
                            selectedStyle = style
                        }
                    } label: {
                        VStack(spacing: 6) {
                            Circle()
                                .fill(stylePreviewColor(style))
                                .frame(width: 36, height: 36)
                                .overlay(
                                    Circle()
                                        .strokeBorder(
                                            selectedStyle == style ? Color.orange : Color.clear,
                                            lineWidth: 2.5
                                        )
                                )

                            Text(style.rawValue)
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(selectedStyle == style ? .primary : .secondary)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .sensoryFeedback(.selection, trigger: selectedStyle)
                }
            }
        }
    }

    private func stylePreviewColor(_ style: ShareCardStyle) -> some ShapeStyle {
        switch style {
        case .dark:
            return AnyShapeStyle(
                LinearGradient(colors: [Color(red: 0.08, green: 0.08, blue: 0.12), Color(red: 0.04, green: 0.04, blue: 0.06)], startPoint: .top, endPoint: .bottom)
            )
        case .ember:
            return AnyShapeStyle(
                LinearGradient(colors: [Color(red: 0.2, green: 0.08, blue: 0.02), Color(red: 0.12, green: 0.04, blue: 0.0)], startPoint: .top, endPoint: .bottom)
            )
        case .frost:
            return AnyShapeStyle(
                LinearGradient(colors: [Color(red: 0.92, green: 0.93, blue: 0.96), Color(red: 0.85, green: 0.86, blue: 0.9)], startPoint: .top, endPoint: .bottom)
            )
        }
    }

    // MARK: - Toggles

    private var toggleOptions: some View {
        VStack(spacing: 10) {
            Toggle(isOn: $showStats) {
                HStack(spacing: 8) {
                    Image(systemName: "chart.bar.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Show Stats")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .tint(.orange)

            Toggle(isOn: $showBranding) {
                HStack(spacing: 8) {
                    Image(systemName: "bitcoinsign.circle.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                    Text("Show Branding")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            .tint(.orange)
        }
        .padding(14)
        .background(Color.primary.opacity(0.05))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Share Button

    private var renderShareButton: some View {
        Button {
            renderAndShare()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                Text("Share to Social Media")
                    .font(.subheadline)
                    .fontWeight(.bold)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.orange, Color(red: 1.0, green: 0.5, blue: 0.1)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(.rect(cornerRadius: 16))
            .shadow(color: .orange.opacity(0.3), radius: 12, y: 4)
        }
    }

    @MainActor
    private func renderAndShare() {
        let renderer = ImageRenderer(content:
            VictoryShareCard(
                question: question,
                streak: streak,
                totalCorrect: totalCorrect,
                totalAnswered: totalAnswered,
                price: price,
                style: selectedStyle,
                showBranding: showBranding,
                showStats: showStats
            )
            .frame(width: 1080)
            .environment(\.colorScheme, selectedStyle == .frost ? .light : .dark)
        )
        renderer.scale = 1.0
        if let image = renderer.uiImage {
            onShare(image)
        }
    }
}

// MARK: - Victory Share Card (Rendered to Image)

struct VictoryShareCard: View {
    let question: DailyQuestion
    let streak: Int
    let totalCorrect: Int
    let totalAnswered: Int
    let price: String
    let style: VictorySharePreview.ShareCardStyle
    let showBranding: Bool
    let showStats: Bool

    private var isFrost: Bool { style == .frost }

    private var bgGradient: LinearGradient {
        switch style {
        case .dark:
            return LinearGradient(
                colors: [
                    Color(red: 0.06, green: 0.06, blue: 0.1),
                    Color(red: 0.02, green: 0.02, blue: 0.04)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .ember:
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.06, blue: 0.0),
                    Color(red: 0.08, green: 0.02, blue: 0.0)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .frost:
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.96, blue: 0.98),
                    Color(red: 0.88, green: 0.89, blue: 0.92)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var accentColor: Color {
        switch style {
        case .dark: return .orange
        case .ember: return Color(red: 1.0, green: 0.6, blue: 0.2)
        case .frost: return Color(red: 0.85, green: 0.5, blue: 0.1)
        }
    }

    private var textPrimary: Color {
        isFrost ? Color(red: 0.1, green: 0.1, blue: 0.12) : .white
    }

    private var textSecondary: Color {
        isFrost ? Color(red: 0.4, green: 0.4, blue: 0.45) : .white.opacity(0.6)
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 28) {
                topBadge
                victoryIcon
                questionSection
                if showStats { statsRow }
                if showBranding { brandingFooter }
            }
            .padding(36)
        }
        .background(bgGradient)
        .overlay(decorativeElements)
    }

    // MARK: - Top Badge

    private var topBadge: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "brain.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(accentColor)
                Text("DAILY BITCOIN BRAIN")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundStyle(accentColor)
                    .tracking(1.5)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 7)
            .background(accentColor.opacity(isFrost ? 0.1 : 0.15))
            .clipShape(Capsule())

            Spacer()

            Text(formattedDate)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(textSecondary)
        }
    }

    // MARK: - Victory Icon

    private var victoryIcon: some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(accentColor.opacity(0.12))
                    .frame(width: 88, height: 88)

                Circle()
                    .fill(accentColor.opacity(0.06))
                    .frame(width: 110, height: 110)

                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 44, weight: .bold))
                    .foregroundStyle(accentColor)
            }

            Text("Nailed It!")
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(textPrimary)

            if streak > 1 {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(accentColor)
                    Text("\(streak)-day streak")
                        .font(.system(size: 14, weight: .heavy))
                        .foregroundStyle(accentColor)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 6)
                .background(accentColor.opacity(isFrost ? 0.08 : 0.12))
                .clipShape(Capsule())
            }
        }
    }

    // MARK: - Question

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Text(question.category.rawValue.uppercased())
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(accentColor)
                    .tracking(1)

                Spacer()

                Text(question.difficulty.rawValue)
                    .font(.system(size: 9, weight: .heavy))
                    .foregroundStyle(textSecondary)
            }

            Text(question.question)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(textPrimary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.2, green: 0.85, blue: 0.5))
                Text(question.choices[question.correctIndex])
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(red: 0.2, green: 0.85, blue: 0.5).opacity(isFrost ? 0.08 : 0.1))
            .clipShape(.rect(cornerRadius: 12))
        }
        .padding(20)
        .background((isFrost ? Color.black : Color.white).opacity(0.05))
        .clipShape(.rect(cornerRadius: 18))
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(icon: "flame.fill", value: "\(streak)", label: "Streak")
            statDivider
            statItem(icon: "checkmark.circle.fill", value: "\(totalCorrect)/\(totalAnswered)", label: "Correct")
            statDivider
            statItem(icon: "bitcoinsign.circle.fill", value: price, label: "BTC Price")
        }
        .padding(14)
        .background((isFrost ? Color.black : Color.white).opacity(0.05))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func statItem(icon: String, value: String, label: String) -> some View {
        VStack(spacing: 5) {
            Image(systemName: icon)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(accentColor)
            Text(value)
                .font(.system(size: 14, weight: .heavy, design: .monospaced))
                .foregroundStyle(textPrimary)
            Text(label)
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var statDivider: some View {
        Rectangle()
            .fill(textSecondary.opacity(0.2))
            .frame(width: 1, height: 36)
    }

    // MARK: - Branding Footer

    private var brandingFooter: some View {
        HStack(spacing: 8) {
            Text("₿")
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(accentColor)
            Text("Fog of Bitcoin")
                .font(.system(size: 13, weight: .heavy))
                .foregroundStyle(textSecondary)
            Spacer()
            Text("Where signal meets uncertainty")
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(textSecondary.opacity(0.6))
                .italic()
        }
        .padding(.top, 4)
    }

    // MARK: - Decorative

    private var decorativeElements: some View {
        ZStack {
            Circle()
                .fill(accentColor.opacity(0.04))
                .frame(width: 300, height: 300)
                .offset(x: -120, y: -180)

            Circle()
                .fill(accentColor.opacity(0.03))
                .frame(width: 200, height: 200)
                .offset(x: 150, y: 200)
        }
        .allowsHitTesting(false)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: Date())
    }
}
