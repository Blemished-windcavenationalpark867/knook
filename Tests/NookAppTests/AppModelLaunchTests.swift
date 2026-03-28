import Foundation
import NookKit
@testable import NookApp
import XCTest

@MainActor
final class AppModelLaunchTests: XCTestCase {
    private final class MockWorkspaceContextProvider: WorkspaceContextProviding {
        var currentSnapshot: WorkspaceContextSnapshot

        init(currentSnapshot: WorkspaceContextSnapshot) {
            self.currentSnapshot = currentSnapshot
        }

        func snapshot() -> WorkspaceContextSnapshot {
            currentSnapshot
        }
    }

    func testCompletedOnboardingLaunchesReadyWithoutOverride() throws {
        let store = try makeStore(with: completedSettings())

        let model = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )

        XCTAssertEqual(model.launchPhase, .ready)
        XCTAssertEqual(model.menuBarMode, .active)
    }

    func testCompletedOnboardingLaunchesSetupWithOverride() throws {
        let store = try makeStore(with: completedSettings())

        let model = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: true),
            startsTimer: false,
            observesSystemEvents: false
        )

        XCTAssertEqual(model.launchPhase, .onboarding)
        XCTAssertEqual(model.menuBarMode, .setup)
    }

    func testIncompleteOnboardingLaunchesSetupWithoutOverride() throws {
        let store = try makeStore(with: .default)

        let model = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )

        XCTAssertEqual(model.launchPhase, .onboarding)
        XCTAssertEqual(model.menuBarMode, .setup)
    }

    func testForcedOnboardingDoesNotPersistResetUntilUserActs() throws {
        let originalSettings = completedSettings()
        let store = try makeStore(with: originalSettings)

        _ = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: true),
            startsTimer: false,
            observesSystemEvents: false
        )

        let reloadedSettings = try store.load()

        XCTAssertEqual(reloadedSettings.onboardingState, originalSettings.onboardingState)
    }

    func testSaveStarterSetupPersistsSettingsButKeepsPresentationOpenUntilFinished() throws {
        let store = try makeStore(with: .default)
        let model = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )
        let draft = StarterSetupDraft(
            preset: .custom,
            workInterval: 30 * 60,
            microBreakDuration: 25,
            launchAtLogin: false,
            postureEnabled: false,
            blinkEnabled: true
        )

        model.openStarterSetup()

        XCTAssertTrue(model.saveStarterSetup(draft: draft))
        XCTAssertEqual(model.launchPhase, .onboarding)
        XCTAssertEqual(model.menuBarMode, .setup)
        XCTAssertTrue(model.onboardingState.hasCompletedStarterSetup)
        XCTAssertNotNil(model.starterSetupViewModel)

        let reloadedSettings = try store.load()
        XCTAssertEqual(reloadedSettings.breakSettings.workInterval, draft.workInterval)
        XCTAssertEqual(reloadedSettings.breakSettings.microBreakDuration, draft.microBreakDuration)
        XCTAssertEqual(reloadedSettings.scheduleSettings.launchAtLogin, draft.launchAtLogin)
        XCTAssertEqual(reloadedSettings.wellnessSettings.posture.isEnabled, draft.postureEnabled)
        XCTAssertEqual(reloadedSettings.wellnessSettings.blink.isEnabled, draft.blinkEnabled)
    }

    func testFinishStarterSetupPresentationTransitionsAppToReady() throws {
        let store = try makeStore(with: .default)
        let model = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )

        model.openStarterSetup()
        XCTAssertTrue(model.saveStarterSetup(draft: .recommended))

        model.finishStarterSetupPresentation(now: Date(timeIntervalSinceReferenceDate: 42))

        XCTAssertEqual(model.launchPhase, .ready)
        XCTAssertEqual(model.menuBarMode, .active)
    }

    func testHandleAppDidFinishLaunchingCreatesStarterSetupViewModelForFirstRun() throws {
        let store = try makeStore(with: .default)
        let model = AppModel(
            settingsStore: store,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )

        model.handleAppDidFinishLaunching(now: Date(timeIntervalSinceReferenceDate: 500))

        XCTAssertEqual(model.launchPhase, .onboarding)
        XCTAssertEqual(model.menuBarMode, .setup)
        XCTAssertNotNil(model.starterSetupViewModel)
    }

    func testHandleAppDidFinishLaunchingPausesForFullscreenFocusWhenEnabled() throws {
        let store = try makeStore(with: completedSettings())
        let workspaceContextProvider = MockWorkspaceContextProvider(
            currentSnapshot: WorkspaceContextSnapshot(
                frontmostApplicationBundleIdentifier: "com.apple.Keynote",
                isFrontmostApplicationFullscreenFocused: true
            )
        )
        let model = AppModel(
            settingsStore: store,
            workspaceContextProvider: workspaceContextProvider,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )

        model.handleAppDidFinishLaunching(now: Date(timeIntervalSinceReferenceDate: 500))

        XCTAssertTrue(model.appState.isPaused)
        XCTAssertEqual(model.appState.pauseReason, "Full-Screen Focus")
    }

    func testSaveSettingsUpdatesSmartPauseProviders() throws {
        var settings = completedSettings()
        settings.smartPauseSettings.pauseDuringFullscreenFocus = false
        let store = try makeStore(with: settings)
        let workspaceContextProvider = MockWorkspaceContextProvider(
            currentSnapshot: WorkspaceContextSnapshot(
                frontmostApplicationBundleIdentifier: "com.apple.Keynote",
                isFrontmostApplicationFullscreenFocused: true
            )
        )
        let model = AppModel(
            settingsStore: store,
            workspaceContextProvider: workspaceContextProvider,
            launchConfiguration: AppLaunchConfiguration(forceOnboarding: false),
            startsTimer: false,
            observesSystemEvents: false
        )

        model.handleAppDidFinishLaunching(now: Date(timeIntervalSinceReferenceDate: 500))
        XCTAssertFalse(model.appState.isPaused)

        model.settings.smartPauseSettings.pauseDuringFullscreenFocus = true
        model.saveSettings()
        model.tick(now: Date(timeIntervalSinceReferenceDate: 560))

        XCTAssertTrue(model.appState.isPaused)
        XCTAssertEqual(model.appState.pauseReason, "Full-Screen Focus")
    }

    private func completedSettings() -> AppSettings {
        var settings = AppSettings.default
        settings.onboardingState = OnboardingState(
            hasCompletedStarterSetup: true,
            completedAt: Date(timeIntervalSinceReferenceDate: 1234),
            lastCompletedVersion: AppSettings.currentSchemaVersion
        )
        return settings
    }

    private func makeStore(with settings: AppSettings) throws -> SettingsStore {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        addTeardownBlock {
            try? FileManager.default.removeItem(at: directory)
        }

        let store = SettingsStore(fileURL: directory.appendingPathComponent("settings.json"))
        try store.save(settings)
        return store
    }
}
