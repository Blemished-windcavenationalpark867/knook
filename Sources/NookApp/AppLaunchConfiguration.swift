import Foundation

struct AppLaunchConfiguration: Sendable, Equatable {
    let forceOnboarding: Bool

    init(forceOnboarding: Bool = false) {
        self.forceOnboarding = forceOnboarding
    }

    init(environment: [String: String]) {
        self.forceOnboarding = Self.parseBoolean(environment["NOOK_FORCE_ONBOARDING"])
    }

    static let current = AppLaunchConfiguration(environment: ProcessInfo.processInfo.environment)

    private static func parseBoolean(_ rawValue: String?) -> Bool {
        guard let normalized = rawValue?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() else {
            return false
        }

        switch normalized {
        case "1", "true", "yes":
            return true
        default:
            return false
        }
    }
}
