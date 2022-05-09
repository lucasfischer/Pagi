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
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) private var phase
    
    var body: some Scene {
        #if os(macOS)
        
        DocumentGroup(newDocument: PagiDocument()) { file in
            ContentView(document: file.$document)
                .preferredColorScheme(theme.colorScheme)
        }
        .commands {
            FindCommands()
            FontCommands(font: $font, fontSize: $fontSize)
            StatsCommands(wordCount: $wordCount, progressBar: $progressBar)
            
            CommandGroup(replacing: .newItem, addition: {
                Button("New") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            })
            
            CommandGroup(replacing: .appInfo, addition: {
                Button("About Pagi") {
                    if let url = URL(string: "pagi://about") {
                        openURL(url)
                    }
                }
            })
        }
        
        Settings {
            SettingsView()
                .preferredColorScheme(theme.colorScheme)
        }
        
        WindowGroup("About Pagi") {
            AboutView()
                .preferredColorScheme(theme.colorScheme)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "about"), allowing: Set(arrayLiteral: "about"))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        
        #elseif os(iOS)
        
        WindowGroup {
            ContentView()
                .preferredColorScheme(theme.colorScheme)
        }
        
        #endif
    }
}
