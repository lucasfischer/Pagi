//
//  ViewCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 09.07.21.
//

import SwiftUI

struct ViewCommands: Commands {
    @Binding var wordCount: Bool
    @Binding var progressBar: Bool
    
    var body: some Commands {
        CommandGroup(after: .toolbar) {
            
            Toggle("Word Count", isOn: $wordCount.animation(.spring()))
                .keyboardShortcut("e", modifiers: .command)
            
            Toggle("Progress Bar", isOn: $progressBar.animation(.spring()))
                .keyboardShortcut("r", modifiers: .command)
            
        }
    }
}
