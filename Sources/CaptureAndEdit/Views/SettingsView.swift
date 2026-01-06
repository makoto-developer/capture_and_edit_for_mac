import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        Form {
            Section {
                Toggle("Auto-close after save", isOn: $viewModel.autoCloseAfterSave)
                    .help("Automatically close the app after saving to clipboard")
            } header: {
                Text("Behavior")
            }
        }
        .padding()
        .frame(width: 400, height: 200)
    }
}
