import AppKit
import Foundation

public final class ActivityMonitor {
    public init() {}

    public var idleSeconds: TimeInterval {
        CGEventSource.secondsSinceLastEventType(.combinedSessionState, eventType: .null)
    }
}

public extension Notification.Name {
    static let nookSystemWillSleep = NSWorkspace.willSleepNotification
    static let nookSystemDidWake = NSWorkspace.didWakeNotification
}
