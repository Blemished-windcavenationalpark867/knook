import NookKit
import SwiftUI

struct SettingsView: View {
    @ObservedObject var model: AppModel

    var body: some View {
        Form {
            Section("Break Rhythm") {
                Stepper(value: $model.settings.breakSettings.workInterval, in: 10 * 60...90 * 60, step: 5 * 60) {
                    labeledValue("Work duration", value: "\(Int(model.settings.breakSettings.workInterval / 60)) min")
                }

                Stepper(value: $model.settings.breakSettings.microBreakDuration, in: 10...120, step: 5) {
                    labeledValue("Break duration", value: "\(Int(model.settings.breakSettings.microBreakDuration)) sec")
                }
            }

            Section("General") {
                Toggle("Launch at login", isOn: $model.settings.scheduleSettings.launchAtLogin)
            }
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(minWidth: 420, minHeight: 240)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Save") {
                    model.saveSettings()
                }
            }
        }
    }

    private func labeledValue(_ title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
