//
//  PagiApp.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

@main
struct PagiApp: App {
    #if os(macOS)
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif
    
    @AppStorage("fontSize") private var fontSize = 18
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("wordCount") private var wordCount = true
    @AppStorage("progressBar") private var progressBar = true
    
    @AppStorage("theme") private var theme = Theme.system
    @Environment(\.colorScheme) var colorScheme
    
    var userColorScheme: ColorScheme? {
        switch theme {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var body: some Scene {
        DocumentGroup(newDocument: PagiDocument()) { file in
            ContentView(document: file.$document)
                .preferredColorScheme(userColorScheme)
        }
        .commands {
            FontCommands(font: $font, fontSize: $fontSize)
            StatsCommands(wordCount: $wordCount, progressBar: $progressBar)
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .preferredColorScheme(userColorScheme)
        }
        #endif
    }
}
