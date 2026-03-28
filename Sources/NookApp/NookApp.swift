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
            MenuBarLabelView(model: model)
        }

        Settings {
            SettingsView(model: model)
        }
    }
}
