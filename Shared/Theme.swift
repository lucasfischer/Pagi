//
//  Theme.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI

enum Theme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    case custom = "Custom"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        case .custom:
            return nil
        }
    }
    
    private var isCustom: Bool { self == .custom }
    
    private var preferences: Preferences { Preferences.shared }
    
    var colors: Colors {
        Colors(
            foreground: isCustom ? preferences.foregroundColor : .foreground,
            foregroundLight: isCustom ? preferences.foregroundColor.opacity(0.7) : .foregroundLight,
            foregroundFaded: isCustom ? preferences.foregroundColor.opacity(0.25) : .foregroundFaded,
            background: isCustom ? preferences.backgroundColor : .background,
            accent: isCustom ? preferences.accentColor : .accentColor
        )
    }
}

extension Theme {
    struct Colors: Equatable {
        var foreground: Color
        var foregroundLight: Color
        var foregroundFaded: Color
        var background: Color
        var accent: Color
    }
}
