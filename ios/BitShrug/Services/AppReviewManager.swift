import StoreKit
import SwiftUI

@Observable
class AppReviewManager {
    static let shared = AppReviewManager()

    private let maxLifetimePrompts = 3
    private let cooldownDays = 30

    private let promptCountKey = "review_prompt_count"
    private let lastPromptDateKey = "review_last_prompt_date"

    private(set) var promptCount: Int
    private var lastPromptDate: Date?

    private init() {
        promptCount = UserDefaults.standard.integer(forKey: promptCountKey)
        if let interval = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Double {
            lastPromptDate = Date(timeIntervalSinceReferenceDate: interval)
        }
    }

    private var canPrompt: Bool {
        guard promptCount < maxLifetimePrompts else { return false }
        if let last = lastPromptDate {
            let daysSince = Calendar.current.dateComponents([.day], from: last, to: Date()).day ?? 0
            return daysSince >= cooldownDays
        }
        return true
    }

    func checkStreakMilestone(_ streak: Int) {
        let triggers: Set<Int> = [7, 14, 30]
        guard triggers.contains(streak) else { return }
        requestReviewIfEligible()
    }

    func checkLessonMilestone(_ completedCount: Int) {
        let triggers: Set<Int> = [5, 10, 25, 50]
        guard triggers.contains(completedCount) else { return }
        requestReviewIfEligible()
    }

    func checkAnsweredMilestone(_ totalCorrect: Int) {
        let triggers: Set<Int> = [5, 10, 25, 50]
        guard triggers.contains(totalCorrect) else { return }
        requestReviewIfEligible()
    }

    private func requestReviewIfEligible() {
        guard canPrompt else { return }

        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first else { return }

        promptCount += 1
        lastPromptDate = Date()
        UserDefaults.standard.set(promptCount, forKey: promptCountKey)
        UserDefaults.standard.set(Date().timeIntervalSinceReferenceDate, forKey: lastPromptDateKey)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
}
