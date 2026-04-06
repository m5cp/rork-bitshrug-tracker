import SwiftUI

struct QuestionOfTheDayView: View {
    let viewModel: BitcoinViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var manager = DailyQuestionManager.shared
    @State private var selectedChoice: Int? = nil
    @State private var showResult: Bool = false
    @State private var showShareCard: Bool = false
    @State private var animateChoices: Bool = false
    @State private var pulseCorrect: Bool = false
    @State private var renderedImage: UIImage?
    @State private var showShareSheet: Bool = false

    private let question: DailyQuestion

    init(viewModel: BitcoinViewModel) {
        self.viewModel = viewModel
        self.question = DailyQuestionManager.shared.todaysQuestion
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    headerSection
                        .padding(.horizontal, 20)
                        .padding(.top, 8)

                    questionCard
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    choicesSection
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    if showResult || manager.hasAnsweredToday {
                        resultSection
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .transition(.asymmetric(
                                insertion: .move(edge: .bottom).combined(with: .opacity),
                                removal: .opacity
                            ))
                    }

                    if (showResult && (manager.wasCorrect || wasCorrectFromSelection)) || (manager.hasAnsweredToday && manager.wasCorrect) {
                        shareButton
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .transition(.scale.combined(with: .opacity))
                    }

                    streakSection
                        .padding(.horizontal, 20)
                        .padding(.top, 24)

                    Spacer(minLength: 60)
                }
            }
            .scrollIndicators(.hidden)
            .fogBackground()
            .navigationTitle("Question of the Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showShareSheet) {
                if let image = renderedImage {
                    ShareSheet(items: [image])
                }
            }
            .sheet(isPresented: $showShareCard) {
                VictorySharePreview(
                    question: question,
                    streak: manager.streak,
                    totalCorrect: manager.totalCorrect,
                    totalAnswered: manager.totalAnswered,
                    price: viewModel.formattedPrice,
                    onShare: { image in
                        renderedImage = image
                        showShareCard = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                            showShareSheet = true
                        }
                    }
                )
                .presentationDetents([.large])
            }
            .onAppear {
                if manager.hasAnsweredToday {
                    showResult = true
                    selectedChoice = manager.selectedIndex
                }
                withAnimation(.spring(duration: 0.6).delay(0.2)) {
                    animateChoices = true
                }
            }
        }
    }

    private var wasCorrectFromSelection: Bool {
        guard let selected = selectedChoice else { return false }
        return selected == question.correctIndex
    }

    // MARK: - Header

    private var headerSection: some View {
        HStack(spacing: 12) {
            Image(systemName: "brain.fill")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.orange)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [.orange.opacity(0.2), .orange.opacity(0.08)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(.rect(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 3) {
                Text("Daily Bitcoin Brain")
                    .font(.headline)
                    .fontWeight(.heavy)

                HStack(spacing: 6) {
                    Text(question.category.rawValue)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.orange)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.12))
                        .clipShape(Capsule())

                    Text(question.difficulty.rawValue)
                        .font(.system(size: 10, weight: .heavy))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color.primary.opacity(0.05))
                        .clipShape(Capsule())
                }
            }

            Spacer()
        }
    }

    // MARK: - Question Card

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "questionmark.circle.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.orange)
                Text("TODAY'S QUESTION")
                    .font(.system(size: 10, weight: .heavy))
                    .foregroundStyle(.orange)
                    .tracking(1.2)
            }

            Text(question.question)
                .font(.title3)
                .fontWeight(.heavy)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.orange.opacity(0.08), Color.orange.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
        )
    }

    // MARK: - Choices

    private var choicesSection: some View {
        VStack(spacing: 10) {
            ForEach(Array(question.choices.enumerated()), id: \.offset) { index, choice in
                choiceButton(index: index, text: choice)
                    .opacity(animateChoices ? 1 : 0)
                    .offset(y: animateChoices ? 0 : 12)
                    .animation(.spring(duration: 0.5).delay(Double(index) * 0.08), value: animateChoices)
            }
        }
    }

    private func choiceButton(index: Int, text: String) -> some View {
        let isAnswered = showResult || manager.hasAnsweredToday
        let isSelected = selectedChoice == index
        let isCorrectAnswer = index == question.correctIndex
        let showAsCorrect = isAnswered && isCorrectAnswer
        let showAsWrong = isAnswered && isSelected && !isCorrectAnswer

        return Button {
            guard !isAnswered else { return }
            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                selectedChoice = index
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                manager.submitAnswer(index)
                withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                    showResult = true
                }
                if index == question.correctIndex {
                    pulseCorrect = true
                }
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    if showAsCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.bullish)
                    } else if showAsWrong {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(AppColors.bearish)
                    } else {
                        Text("\(Character(UnicodeScalar(65 + index)!))")
                            .font(.system(size: 13, weight: .heavy, design: .monospaced))
                            .foregroundStyle(isSelected ? .white : .primary)
                            .frame(width: 30, height: 30)
                            .background(isSelected ? Color.orange : Color.primary.opacity(0.06))
                            .clipShape(Circle())
                    }
                }
                .frame(width: 30, height: 30)

                Text(text)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)

                Spacer(minLength: 0)
            }
            .padding(16)
            .background(choiceBackground(showAsCorrect: showAsCorrect, showAsWrong: showAsWrong, isSelected: isSelected && !isAnswered))
            .clipShape(.rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        showAsCorrect ? AppColors.bullish.opacity(0.4) :
                        showAsWrong ? AppColors.bearish.opacity(0.4) :
                        isSelected && !isAnswered ? Color.orange.opacity(0.4) :
                        Color.primary.opacity(0.06),
                        lineWidth: 1
                    )
            )
            .scaleEffect(showAsCorrect && pulseCorrect ? 1.02 : 1.0)
            .animation(.spring(duration: 0.4), value: pulseCorrect)
        }
        .buttonStyle(.plain)
        .disabled(isAnswered)
        .sensoryFeedback(showAsCorrect ? .success : showAsWrong ? .error : .selection, trigger: showResult)
    }

    private func choiceBackground(showAsCorrect: Bool, showAsWrong: Bool, isSelected: Bool) -> some ShapeStyle {
        if showAsCorrect {
            return AnyShapeStyle(AppColors.bullish.opacity(0.1))
        } else if showAsWrong {
            return AnyShapeStyle(AppColors.bearish.opacity(0.1))
        } else if isSelected {
            return AnyShapeStyle(Color.orange.opacity(0.08))
        } else {
            return AnyShapeStyle(Color(.secondarySystemGroupedBackground))
        }
    }

    // MARK: - Result

    private var resultSection: some View {
        let correct = manager.wasCorrect || wasCorrectFromSelection

        return VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 10) {
                Image(systemName: correct ? "party.popper.fill" : "lightbulb.fill")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(correct ? .orange : .yellow)

                Text(correct ? "Correct!" : "Not quite!")
                    .font(.title3)
                    .fontWeight(.heavy)
                    .foregroundStyle(correct ? AppColors.bullish : .primary)
            }

            Divider()
                .overlay(Color.primary.opacity(0.06))

            Text(question.explanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
                .fixedSize(horizontal: false, vertical: true)

            if !correct {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.bullish)
                    Text("Correct answer: \(question.choices[question.correctIndex])")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(18)
        .background(
            LinearGradient(
                colors: correct
                    ? [AppColors.bullish.opacity(0.08), AppColors.bullish.opacity(0.02)]
                    : [Color.primary.opacity(0.06), Color.primary.opacity(0.02)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(
                    correct ? AppColors.bullish.opacity(0.2) : Color.primary.opacity(0.06),
                    lineWidth: 1
                )
        )
    }

    // MARK: - Share Button

    private var shareButton: some View {
        Button {
            showShareCard = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 14, weight: .bold))
                Text("Share Your Victory")
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
        .sensoryFeedback(.success, trigger: showShareCard)
    }

    // MARK: - Streak

    private var streakSection: some View {
        HStack(spacing: 16) {
            streakStat(icon: "flame.fill", color: .orange, value: "\(manager.streak)", label: "Streak")
            streakStat(icon: "checkmark.circle.fill", color: AppColors.bullish, value: "\(manager.totalCorrect)", label: "Correct")
            streakStat(icon: "brain.fill", color: .purple, value: "\(manager.totalAnswered)", label: "Answered")
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        )
    }

    private func streakStat(icon: String, color: Color, value: String, label: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
            Text(value)
                .font(.system(size: 18, weight: .heavy, design: .monospaced))
            Text(label)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}
