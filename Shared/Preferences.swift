//
//  Preferences.swift
//  Pagi
//
//  Created by Lucas Fischer on 03.02.23.
//

import SwiftUI

@MainActor
class Preferences: ObservableObject {
    
    static let shared = Preferences()
    
    @AppStorage("isOnboardingPresented") var isOnboardingPresented = true
    
    @AppStorage("exportType") var exportType: FileType = .text
    @AppStorage("wordTarget") var wordTarget = 750
    @AppStorage("wordCount") var wordCount = true
    @AppStorage("progressBar") var progressBar = true
    @AppStorage("isSpellCheckingEnabled") var isSpellCheckingEnabled = false
    @AppStorage("isAutocorrectionEnabled") var isAutocorrectionEnabled = false
    @AppStorage("focusMode") var isFocusModeEnabled = false
    @AppStorage("focusType") var focusType = FocusType.sentence
    
    @AppStorage("theme") var theme = Theme.system
    @AppStorage("font") var font = iAFont.duo
    @AppStorage("fontSize") var fontSize = 18.0
    
    @AppStorage("foregroundColor") var foregroundColor = Color.foreground
    @AppStorage("backgroundColor") var backgroundColor = Color.background
    @AppStorage("accentColor") var accentColor = Color.accentColor
    
    @AppStorage("haptics") var isHapticsEnabled = true
}
