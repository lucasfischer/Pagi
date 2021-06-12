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
    
    var body: some Scene {
        DocumentGroup(newDocument: PagiDocument()) { file in
            ContentView(document: file.$document)
        }
        .commands {
            FontCommands()
        }
        
        #if os(macOS)
        Settings {
            SettingsView()
        }
        #endif
    }
}
