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
    case blackWhite
    case futureland
    case oneDark
    case neon
    case pastel
    case custom
    
    var text: Text {
        switch self {
            case .system:
                Text("System")
            case .light:
                Text("Light")
            case .dark:
                Text("Dark")
            case .blackWhite:
                Text(verbatim: "B/W")
            case .futureland:
                Text(verbatim: "Futureland")
            case .oneDark:
                Text(verbatim: "One Dark")
            case .neon:
                Text(verbatim: "Neon")
            case .pastel:
                Text(verbatim: "Pastel")
            case .custom:
                Text("Custom")
        }
    }
    
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system, .custom:
            return nil
        case .light, .pastel:
            return .light
        case .blackWhite, .dark, .oneDark, .neon, .futureland:
            return .dark
        }
    }
    
    private var preferences: Preferences { Preferences.shared }
    
    var colors: Colors {
        var foreground = Color.foreground
        var background = Color.background
        var accent = Color.accentColor
        
        switch self {
        case .light:
            return Colors(
                foreground: Color(red: 0.267, green: 0.267, blue: 0.267),
                foregroundLight: Color(red: 0.467, green: 0.467, blue: 0.467),
                foregroundFaded: Color(red: 0.772, green: 0.772, blue: 0.772),
                background: Color(red: 0.957, green: 0.961, blue: 0.961),
                accent: Color(red: 0.553, green: 0.863, blue: 0.765)
            )
        case .dark:
            return Colors(
                foreground: Color.white,
                foregroundLight: Color(red: 0.467, green: 0.467, blue: 0.467),
                foregroundFaded: Color(red: 0.467, green: 0.467, blue: 0.467),
                background: Color(red: 0.133, green: 0.133, blue: 0.137),
                accent: Color(red: 0.957, green: 0.722, blue: 0.361)
            )
        case .custom:
            foreground = preferences.foregroundColor
            background = preferences.backgroundColor
            accent = preferences.accentColor
        case .blackWhite:
            foreground = .white
            background = .black
            accent = .white
        case .futureland:
            foreground = Color(hex: "#A5A5A5")
            background = Color(hex: "#000000")
            accent = Color(hex: "#9A98FF")
        case .oneDark:
            foreground = Color(hex: "#ABB1BD")
            background = Color(hex: "#292B32")
            accent = Color(hex: "#D07177")
        case .neon:
            foreground = Color(hex: "#E797CE")
            background = Color(hex: "#1E142D")
            accent = Color(hex: "#EB5267")
        case .pastel:
            foreground = Color(hex: "#524135")
            background = Color(hex: "#E5DFDA")
            accent = Color(hex: "#9E8C96")
        default:
            break
        }
        
        return Colors(
            foreground: foreground,
            foregroundLight: foreground.opacity(0.7),
            foregroundFaded: foreground.opacity(0.25),
            background: background,
            accent: accent
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
