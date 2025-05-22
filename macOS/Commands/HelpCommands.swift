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
            Link("Website", destination: Configuration.webURL)
            
            Link("Contact Developer", destination: Configuration.supportEmailAddressURL)
            
            Link("Rate Pagi", destination: URL(string: "https://apps.apple.com/app/id1586446074?action=write-review")!)
            
            Link("Development Journal", destination: URL(string: "https://futureland.tv/lucas/pagi")!)
        }
    }
}
