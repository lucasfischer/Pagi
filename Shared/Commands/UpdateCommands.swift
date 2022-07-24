//
//  UpdateCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 24.07.22.
//

import SwiftUI
import Sparkle

// This view model class manages Sparkle's updater and publishes when new updates are allowed to be checked
final class UpdaterViewModel: ObservableObject {
    private let updater = SUUpdater.shared()!
    
    @Published var updateInProgress = false
    
    init() {
        updater.publisher(for: \.updateInProgress)
            .assign(to: &$updateInProgress)
    }
    
    func checkForUpdates() {
        updater.checkForUpdates(self)
    }
}

struct UpdateCommands: Commands {
    @StateObject var updaterViewModel = UpdaterViewModel()
    
    var body: some Commands {
        CommandGroup(after: .appInfo) {
            Button("Check for Updates…", action: updaterViewModel.checkForUpdates)
                .disabled(updaterViewModel.updateInProgress)
        }
    }
}
