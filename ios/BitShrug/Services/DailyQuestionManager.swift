import Foundation

@Observable
class DailyQuestionManager {
    static let shared = DailyQuestionManager()

    private(set) var todaysQuestion: DailyQuestion
    private(set) var hasAnsweredToday: Bool = false
    private(set) var wasCorrect: Bool = false
    private(set) var selectedIndex: Int? = nil
    private(set) var streak: Int = 0
    private(set) var totalCorrect: Int = 0
    private(set) var totalAnswered: Int = 0

    private let answeredDateKey = "qotd_answered_date"
    private let wasCorrectKey = "qotd_was_correct"
    private let selectedIndexKey = "qotd_selected_index"
    private let streakKey = "qotd_streak"
    private let totalCorrectKey = "qotd_total_correct"
    private let totalAnsweredKey = "qotd_total_answered"
    private let questionIDKey = "qotd_question_id"

    private init() {
        let question = Self.questionForToday()
        self.todaysQuestion = question

        streak = UserDefaults.standard.integer(forKey: streakKey)
        totalCorrect = UserDefaults.standard.integer(forKey: totalCorrectKey)
        totalAnswered = UserDefaults.standard.integer(forKey: totalAnsweredKey)

        if Self.isToday(UserDefaults.standard.string(forKey: answeredDateKey)),
           UserDefaults.standard.string(forKey: questionIDKey) == question.id {
            hasAnsweredToday = true
            wasCorrect = UserDefaults.standard.bool(forKey: wasCorrectKey)
            selectedIndex = UserDefaults.standard.object(forKey: selectedIndexKey) as? Int
        }
    }

    func submitAnswer(_ index: Int) {
        guard !hasAnsweredToday else { return }

        let correct = index == todaysQuestion.correctIndex
        hasAnsweredToday = true
        wasCorrect = correct
        selectedIndex = index
        totalAnswered += 1

        if correct {
            totalCorrect += 1
            streak += 1
        } else {
            streak = 0
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        UserDefaults.standard.set(formatter.string(from: Date()), forKey: answeredDateKey)
        UserDefaults.standard.set(correct, forKey: wasCorrectKey)
        UserDefaults.standard.set(index, forKey: selectedIndexKey)
        UserDefaults.standard.set(todaysQuestion.id, forKey: questionIDKey)
        UserDefaults.standard.set(streak, forKey: streakKey)
        UserDefaults.standard.set(totalCorrect, forKey: totalCorrectKey)
        UserDefaults.standard.set(totalAnswered, forKey: totalAnsweredKey)
    }

    private static func questionForToday() -> DailyQuestion {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        var hasher = Hasher()
        hasher.combine(dateString)
        hasher.combine("BitShrug_QOTD_v1")
        let hash = abs(hasher.finalize())
        let index = hash % DailyQuestion.bank.count
        return DailyQuestion.bank[index]
    }

    private static func isToday(_ dateString: String?) -> Bool {
        guard let dateString else { return false }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return dateString == formatter.string(from: Date())
    }
}
