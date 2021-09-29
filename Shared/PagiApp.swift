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
    
    init() {
        setupColorScheme()
    }
   
    private func setupColorScheme() {
        #if os(iOS)
        var style = UIUserInterfaceStyle.dark
        switch theme {
        case .system:
            style = .unspecified
        case .light:
            style = .light
        case .dark:
            style = .dark
        }
        let window = UIApplication.shared.windows.first
        window?.overrideUserInterfaceStyle = style
        #endif
    }
    
    var body: some Scene {
        DocumentGroup(newDocument: PagiDocument()) { file in
            ContentView(document: file.$document)
                .preferredColorScheme(userColorScheme)
        }
        .commands {
            FontCommands(font: $font, fontSize: $fontSize)
            StatsCommands(wordCount: $wordCount, progressBar: $progressBar)
            
            #if os(macOS)
            CommandGroup(replacing: .newItem, addition: {
                Button("New") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            })
            #endif
            
            CommandGroup(replacing: .appInfo, addition: {
                Button("About Pagi") {
                    if let url = URL(string: "pagi://about") {
                        openURL(url)
                    }
                }
            })
        }
        .onChange(of: phase) { _ in
            setupColorScheme()
        }
        .onChange(of: theme) { _ in
            setupColorScheme()
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
                .preferredColorScheme(userColorScheme)
        }
        
        WindowGroup("About Pagi") {
            AboutView()
                .preferredColorScheme(userColorScheme)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "about"), allowing: Set(arrayLiteral: "about"))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        #endif
    }
}
