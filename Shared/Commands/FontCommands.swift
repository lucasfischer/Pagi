//
//  FontCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 12.06.21.
//

import SwiftUI

struct FontCommands: Commands {
    @Binding var font: iAFont
    @Binding var fontSize: Int
    
    var body: some Commands {
        CommandMenu("Font") {
            Picker("Font", selection: $font) {
                ForEach(iAFont.allCases, id: \.self) { font in
                    Text(verbatim: font.rawValue)
                }
            }
            
            Divider()
            
            Button("Increase Size") {
                if fontSize < 40 {
                    fontSize += 1
                }
            }
            .keyboardShortcut("+", modifiers: .command)
            
            Button("Default Size") {
                fontSize = 18
            }
            .keyboardShortcut("0", modifiers: .command)
            
            Button("Decrease Size") {
                if fontSize > 10 {
                    fontSize -= 1
                }
            }
            .keyboardShortcut("-", modifiers: .command)
        }
    }
}
