import Foundation

@Observable
class LearnProgressManager {
    static let shared = LearnProgressManager()

    private let key = "learn_completed_lessons"
    private(set) var completedLessons: Set<String> = []

    private init() {
        if let saved = UserDefaults.standard.array(forKey: key) as? [String] {
            completedLessons = Set(saved)
        }
    }

    func markRead(_ lessonID: String) {
        guard !completedLessons.contains(lessonID) else { return }
        completedLessons.insert(lessonID)
        save()
        AppReviewManager.shared.checkLessonMilestone(completedLessons.count)
    }

    func isRead(_ lessonID: String) -> Bool {
        completedLessons.contains(lessonID)
    }

    func completedCount(for topic: String) -> Int {
        completedLessons.filter { $0.hasPrefix(topic + "_") }.count
    }

    func reset() {
        completedLessons.removeAll()
        save()
    }

    private func save() {
        UserDefaults.standard.set(Array(completedLessons), forKey: key)
    }
}
