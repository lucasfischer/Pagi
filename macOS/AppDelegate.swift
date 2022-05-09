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
}

// MARK: Sparkle
extension AppDelegate {
    private func setupSparkle() {
        guard let updater = SUUpdater.shared() else { return }
        updater.delegate = self
    }
}
