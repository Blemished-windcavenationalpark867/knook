import SwiftUI

@main
struct NookApp: App {
    @NSApplicationDelegateAdaptor(NookApplicationDelegate.self) private var appDelegate
    @StateObject private var model: AppModel

    init() {
        NookApplicationDelegate.configureAppIcon()
        let model = AppModel()
        _model = StateObject(wrappedValue: model)
        NookApplicationDelegate.didFinishLaunchingHandler = { [weak model] in
            model?.handleAppDidFinishLaunching()
        }
    }

    var body: some Scene {
        MenuBarExtra {
            StatusMenuView(model: model)
        } label: {
            menuBarLabel
        }

        Settings {
            SettingsView(model: model)
        }
    }

    @ViewBuilder
    private var menuBarLabel: some View {
        if let countdownText = urgentCountdownText {
            Text(countdownText)
                .monospacedDigit()
        } else {
            MenuBarIcon()
        }
    }

    private var urgentCountdownText: String? {
        guard model.launchPhase == .ready else { return nil }

        if let activeBreak = model.appState.activeBreak {
            let remaining = max(activeBreak.scheduledEnd.timeIntervalSince(model.appState.now), 0)
            if remaining <= 60 {
                return "\(Int(remaining))s"
            }
            return nil
        }

        if let nextBreakDate = model.appState.nextBreakDate {
            let remaining = max(nextBreakDate.timeIntervalSince(model.appState.now), 0)
            if remaining <= 10 {
                return "Break in \(Int(remaining))s"
            } else if remaining <= 60 {
                return "\(Int(remaining))s"
            }
            return nil
        }

        return nil
    }
}

private struct MenuBarIcon: View {
    var body: some View {
        Image(systemName: "pause.fill")
    }
}
