//
//  Preferences.swift
//  Pagi
//
//  Created by Lucas Fischer on 03.02.23.
//

import SwiftUI

class Preferences: ObservableObject {
    
    static let shared = Preferences()
    
    @AppStorage("wordTarget") var wordTarget = 1500
    @AppStorage("wordCount") var wordCount = true
    @AppStorage("progressBar") var progressBar = true
    @AppStorage("isSpellCheckingEnabled") var isSpellCheckingEnabled = false
    @AppStorage("focusMode") var isFocusModeEnabled = false
    @AppStorage("focusType") var focusType = FocusType.sentence
    
    @AppStorage("theme") var theme = Theme.system
    @AppStorage("font") var font = iAFont.duo
    @AppStorage("fontSize") var fontSize = 18.0
}
