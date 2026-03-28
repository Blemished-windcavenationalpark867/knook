@testable import NookApp
import XCTest

final class NookApplicationDelegateTests: XCTestCase {
    func testUsesRuntimeIconOutsideAppBundle() {
        let bundleURL = URL(fileURLWithPath: "/tmp/Nook", isDirectory: true)

        XCTAssertTrue(NookApplicationDelegate.shouldApplyRuntimeIcon(bundleURL: bundleURL))
    }

    func testSkipsRuntimeIconInsideAppBundle() {
        let bundleURL = URL(fileURLWithPath: "/Applications/Nook.app", isDirectory: true)

        XCTAssertFalse(NookApplicationDelegate.shouldApplyRuntimeIcon(bundleURL: bundleURL))
    }
}
