//
//  Haptics.swift
//  Pagi (iOS)
//
//  Created by Lucas Fischer on 12.03.23.
//

import SwiftUI

@MainActor
enum Haptics {
    
    @AppStorage("isHapticsEnabled") static var isHapticsEnabled = true
    
    static func selectionChanged() {
        if isHapticsEnabled {
            UISelectionFeedbackGenerator().selectionChanged()
        }
    }
    
    static func impactOccurred(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        if isHapticsEnabled {
            UIImpactFeedbackGenerator(style: style).impactOccurred()
        }
    }
    
    static func notificationOccurred(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        if isHapticsEnabled {
            UINotificationFeedbackGenerator().notificationOccurred(type)
        }
    }
    
}

