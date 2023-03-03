//
//  PagiApp.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

@main
struct PagiApp: App {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    @Environment(\.scenePhase) private var phase
    
    @StateObject private var preferences = Preferences.shared
    #if os(iOS)
    @StateObject private var viewModel = ContentView.ViewModel()
    #endif
    
    var body: some Scene {
        #if os(macOS)
        
        DocumentGroup(newDocument: PagiDocument()) { file in
            ContentView(document: file.$document)
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        .commands {
            FindCommands()
            FontCommands(font: $preferences.font, fontSize: $preferences.fontSize)
            ViewCommands(
                wordCount: $preferences.wordCount,
                progressBar: $preferences.progressBar
            )
            FocusCommands(
                focusMode: $preferences.isFocusModeEnabled,
                focusType: $preferences.focusType
            )
            HelpCommands()
            
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
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        
        WindowGroup("About Pagi") {
            AboutView()
                .preferredColorScheme(preferences.theme.colorScheme)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "about"), allowing: Set(arrayLiteral: "about"))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowNotResizable()
        
        #elseif os(iOS)
        
        WindowGroup {
            ContentView(viewModel: viewModel)
                .tint(preferences.theme.colors.accent)
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        .commands {
            FontCommands(font: $preferences.font, fontSize: $preferences.fontSize)
            FocusCommands(
                focusMode: $preferences.isFocusModeEnabled,
                focusType: $preferences.focusType
            )
            ViewCommands(viewModel: viewModel, wordCount: $preferences.wordCount, progressBar: $preferences.progressBar)
        }
        
        #endif
    }
}
