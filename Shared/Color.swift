//
//  Color.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI
#if os(iOS)
typealias PlatformColor = UIColor
#elseif os(macOS)
typealias PlatformColor = NSColor
#endif

extension Color {
    static let foreground = Color("Foreground")
    static let foregroundFaded = Color("ForegroundFaded")
    static let foregroundLight = Color("ForegroundLight")
    static let background = Color("Background")
}

extension Color: RawRepresentable {
    
    public init?(rawValue: String) {
        
        guard let data = Data(base64Encoded: rawValue) else {
            self = .black
            return
        }
        
        do {
            let color = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? PlatformColor ?? .black
            self = Color(color)
        } catch {
            self = .black
        }
        
    }
    
    public var rawValue: String {
        
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: PlatformColor(self), requiringSecureCoding: false) as Data
            return data.base64EncodedString()
        } catch {
            return ""
        }
        
    }
}
