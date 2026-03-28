import Foundation

public final class SettingsStore {
    public let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(fileURL: URL = SettingsStore.defaultFileURL) {
        self.fileURL = fileURL
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    }

    public func load() throws -> AppSettings {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return .default
        }

        let data = try Data(contentsOf: fileURL)
        let decoded = try decoder.decode(AppSettings.self, from: data)
        let migrated = decoded.migrated()
        if migrated != decoded {
            try save(migrated)
        }
        return migrated
    }

    public func save(_ settings: AppSettings) throws {
        let data = try encoder.encode(settings.migrated())
        try FileManager.default.createDirectory(
            at: fileURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        try data.write(to: fileURL, options: .atomic)
    }

    public static var defaultFileURL: URL {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        return base
            .appendingPathComponent("Nook", isDirectory: true)
            .appendingPathComponent("settings.json", isDirectory: false)
    }
}
