import Foundation
import NookKit
import XCTest

final class SettingsStoreTests: XCTestCase {
    func testSettingsStorePersistsAndLoadsMigratedSettings() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("settings.json")
        let store = SettingsStore(fileURL: fileURL)

        var settings = AppSettings.default
        settings.schemaVersion = 0
        try store.save(settings)

        let loaded = try store.load()

        XCTAssertEqual(loaded.schemaVersion, AppSettings.currentSchemaVersion)
        XCTAssertEqual(loaded.breakSettings, settings.breakSettings)
        XCTAssertEqual(loaded.smartPauseSettings, settings.smartPauseSettings)
    }

    func testMissingSmartPauseSettingsUseMigratedDefaults() throws {
        let directory = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        let fileURL = directory.appendingPathComponent("settings.json")
        let store = SettingsStore(fileURL: fileURL)
        let legacyJSON = """
        {
          "schemaVersion" : 3,
          "breakSettings" : {
            "allowEarlyEnd" : true,
            "backgroundStyle" : "dawn",
            "customMessages" : [
              "Look across the room and relax your focus."
            ],
            "longBreakCadence" : 3,
            "longBreakDuration" : 300,
            "longBreaksEnabled" : true,
            "microBreakDuration" : 20,
            "reminderLeadTime" : 60,
            "selectedSound" : "breeze",
            "skipPolicy" : "balanced",
            "workInterval" : 1200
          },
          "contextualEducationState" : {
            "hasSeenFirstBreakHint" : true,
            "hasSeenFirstWellnessHint" : true
          },
          "onboardingState" : {
            "hasCompletedStarterSetup" : true
          },
          "scheduleSettings" : {
            "idleResetThreshold" : 300,
            "launchAtLogin" : true,
            "officeHours" : []
          },
          "wellnessSettings" : {
            "blink" : {
              "deliveryStyle" : "panel",
              "interval" : 600,
              "isEnabled" : false
            },
            "posture" : {
              "deliveryStyle" : "panel",
              "interval" : 1800,
              "isEnabled" : false
            }
          }
        }
        """

        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        guard let legacyData = legacyJSON.data(using: .utf8) else {
            XCTFail("Expected legacy JSON data")
            return
        }
        try legacyData.write(to: fileURL)

        let loaded = try store.load()

        XCTAssertEqual(loaded.schemaVersion, AppSettings.currentSchemaVersion)
        XCTAssertFalse(loaded.smartPauseSettings.pauseDuringFullscreenFocus)
    }
}
