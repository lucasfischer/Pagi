//
//  FindCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 09.05.22.
//

import SwiftUI

struct FindCommands: Commands {
    
    func performTextFinderAction(_ action: NSTextFinder.Action) {
        if let textView = NSApplication.shared.mainWindow?.firstResponder as? NSTextView {
            let control = NSControl()
            control.tag = action.rawValue
            textView.performTextFinderAction(control)
        }
    }
    
    var body: some Commands {
        CommandGroup(after: .textEditing) {
            Menu("Find") {
                Button("Find...") {
                    performTextFinderAction(.showFindInterface)
                }
                .keyboardShortcut("f", modifiers: .command)
                
                Button("Find and Replace...") {
                    performTextFinderAction(.showReplaceInterface)
                }
                .keyboardShortcut("f", modifiers: [.command, .option])
                
                Button("Find Next") {
                    performTextFinderAction(.nextMatch)
                }
                .keyboardShortcut("g", modifiers: .command)
                
                Button("Find Previous") {
                    performTextFinderAction(.previousMatch)
                }
                .keyboardShortcut("g", modifiers: [.command, .shift])
            }
        }
    }
}
