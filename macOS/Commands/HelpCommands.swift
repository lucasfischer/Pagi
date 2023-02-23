//
//  HelpCommands.swift
//  Pagi
//
//  Created by Lucas Fischer on 23.02.23.
//

import SwiftUI
import AppKit

struct HelpCommands: Commands {
    var body: some Commands {
        CommandGroup(replacing: .help) {
            Link("Website", destination: URL(string: "https://pagi.lucas.love")!)
            
            Link("Contact Developer", destination: URL(string: "mailto:xoxo@lucas.love?subject=Pagi")!)
            
            Link("Rate Pagi", destination: URL(string: "https://apps.apple.com/app/id1586446074?action=write-review")!)
            
            Link("Development Journal", destination: URL(string: "https://futureland.tv/lucas/pagi")!)
        }
    }
}
