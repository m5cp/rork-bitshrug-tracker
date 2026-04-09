import ActivityKit
import Foundation

class LiveActivityManager {
    static let shared = LiveActivityManager()
    private var currentActivity: Activity<TouchGrassBTCLiveAttributes>?

    private init() {}

    var isRunning: Bool {
        currentActivity != nil
    }

    func start(price: Double, change24h: Double, score: Int, label: String) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }

        end()

        let attributes = TouchGrassBTCLiveAttributes(appName: "Fog of Bitcoin")
        let state = TouchGrassBTCLiveAttributes.ContentState(
            price: price,
            change24h: change24h,
            environmentScore: score,
            environmentLabel: label,
            lastUpdated: Date()
        )

        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: .init(state: state, staleDate: Date().addingTimeInterval(30 * 60)),
                pushType: nil
            )
        } catch {
            print("[TouchGrassBTC] Live Activity start failed: \(error.localizedDescription)")
        }
    }

    func update(price: Double, change24h: Double, score: Int, label: String) {
        guard let activity = currentActivity else {
            start(price: price, change24h: change24h, score: score, label: label)
            return
        }

        let state = TouchGrassBTCLiveAttributes.ContentState(
            price: price,
            change24h: change24h,
            environmentScore: score,
            environmentLabel: label,
            lastUpdated: Date()
        )

        Task {
            await activity.update(.init(state: state, staleDate: Date().addingTimeInterval(30 * 60)))
        }
    }

    func end() {
        guard let activity = currentActivity else { return }
        let finalState = activity.content.state
        Task {
            await activity.end(.init(state: finalState, staleDate: nil), dismissalPolicy: .immediate)
        }
        currentActivity = nil
    }
}
