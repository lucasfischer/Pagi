//
//  FontCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 12.06.21.
//

import SwiftUI

struct FontCommands: Commands {
    @AppStorage("fontSize") private var fontSize = 18
    @AppStorage("font") private var font = iAFont.duo
    
    var body: some Commands {
        CommandMenu("Font") {
            Picker("Font", selection: $font) {
                ForEach(iAFont.allCases, id: \.self) { font in
                    Text("\(font.rawValue)")
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
