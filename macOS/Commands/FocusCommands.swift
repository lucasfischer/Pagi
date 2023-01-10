//
//  FocusCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 24.07.22.
//

import SwiftUI

struct FocusCommands: Commands {
    
    @Binding var focusMode: Bool
    @Binding var focusType: FocusType
    
    var body: some Commands {
        CommandMenu("Focus") {
            Toggle(focusMode ? "Disable Focus Mode" : "Enable Focus Mode", isOn: $focusMode)
                .keyboardShortcut("d", modifiers: .command)
            
            Picker("Mode", selection: $focusType) {
                ForEach(FocusType.allCases, id: \.self) { type in
                    Button(type.title) {
                        focusType = type
                    }
                }
            }.pickerStyle(.inline)
            
        }
    }
}
