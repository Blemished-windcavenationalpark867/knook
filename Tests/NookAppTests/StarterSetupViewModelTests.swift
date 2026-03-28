import Foundation
@testable import NookApp
import XCTest

@MainActor
final class StarterSetupViewModelTests: XCTestCase {
    func testStartsOnWelcomeStep() {
        let model = makeViewModel()

        XCTAssertEqual(model.currentStep, .welcome)
    }

    func testContinueFromWelcomeAdvancesToSchedule() {
        let model = makeViewModel()

        model.continueFromWelcome()

        XCTAssertEqual(model.currentStep, .schedule)
    }

    func testContinueFromScheduleCommitsDraftShowsCompleteAndFinishes() async {
        var committedDraft: StarterSetupDraft?
        var didFinish = false
        let model = makeViewModel(
            completionDelay: .zero,
            onCommit: { draft in
                committedDraft = draft
                return true
            },
            onFinish: {
                didFinish = true
            }
        )

        model.continueFromWelcome()
        model.adjustWorkInterval(30 * 60)
        model.adjustMicroBreakDuration(25)

        model.continueFromSchedule()

        XCTAssertEqual(model.currentStep, .complete)
        XCTAssertEqual(committedDraft?.workInterval, 30 * 60)
        XCTAssertEqual(committedDraft?.microBreakDuration, 25)

        await Task.yield()

        XCTAssertTrue(didFinish)
    }

    func testContinueFromScheduleStaysOnScheduleWhenCommitFails() {
        var commitCount = 0
        let model = makeViewModel(onCommit: { _ in
            commitCount += 1
            return false
        })

        model.continueFromWelcome()
        model.continueFromSchedule()

        XCTAssertEqual(commitCount, 1)
        XCTAssertEqual(model.currentStep, .schedule)
    }

    func testNotNowDismissesWithRecommendedDraft() {
        var dismissedDraft: StarterSetupDraft?
        let model = makeViewModel(onDismiss: { draft in
            dismissedDraft = draft
        })

        model.adjustWorkInterval(45 * 60)
        model.notNow()

        XCTAssertEqual(dismissedDraft, .recommended)
    }

    private func makeViewModel(
        completionDelay: Duration = .seconds(1),
        onCommit: @escaping (StarterSetupDraft) -> Bool = { _ in true },
        onFinish: @escaping () -> Void = {},
        onDismiss: @escaping (StarterSetupDraft) -> Void = { _ in }
    ) -> StarterSetupViewModel {
        StarterSetupViewModel(
            completionDelay: completionDelay,
            onCommit: onCommit,
            onFinish: onFinish,
            onDismiss: onDismiss
        )
    }
}
