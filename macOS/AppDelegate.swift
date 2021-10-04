//
//  AppDelegate.swift
//  Pagi (macOS)
//
//  Created by Lucas Fischer on 06.06.21.
//

import AppKit
import Sparkle

class AppDelegate: NSObject, NSApplicationDelegate, SUUpdaterDelegate {
    func applicationWillFinishLaunching(_ notification: Notification) {
        setupSparkle()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        // Open empty document after becoming active
        if NSDocumentController.shared.documents.count == 0 {
            NSDocumentController.shared.newDocument(nil)
        }
    }
}

// MARK: Sparkle
extension AppDelegate {
    private func setupSparkle() {
        guard let updater = SUUpdater.shared() else { return }
        updater.delegate = self
    }
}
