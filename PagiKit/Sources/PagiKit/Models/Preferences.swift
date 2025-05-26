import SwiftUI

@MainActor
public class Preferences: ObservableObject {
    
    public static let shared = Preferences()
    
    @AppStorage("isOnboardingPresented") public var isOnboardingPresented = true
    @AppStorage("onBoardingCompletedAt") public var onBoardingCompletedAt: TimeInterval?
    
    @AppStorage("exportType") public var exportType: FileType = .text
    @AppStorage("wordTarget") public var wordTarget = Configuration.defaultWordTarget
    @AppStorage("wordCount") public var wordCount = true
    @AppStorage("progressBar") public var progressBar = true
    @AppStorage("isSpellCheckingEnabled") public var isSpellCheckingEnabled = false
    @AppStorage("isAutocorrectionEnabled") public var isAutocorrectionEnabled = false
    @AppStorage("focusMode") public var isFocusModeEnabled = false
    @AppStorage("focusType") public var focusType = FocusType.sentence
    
    @AppStorage("theme") public var theme = Theme.system
    @AppStorage("font") public var font = iAFont.duo
    @AppStorage("fontSize") public var fontSize = 18.0
    
    @AppStorage("foregroundColor") public var foregroundColor = Color.foreground
    @AppStorage("backgroundColor") public var backgroundColor = Color.background
    @AppStorage("accentColor") public var accentColor = Color.accentColor
    
    @AppStorage("haptics") public var isHapticsEnabled = true
}
