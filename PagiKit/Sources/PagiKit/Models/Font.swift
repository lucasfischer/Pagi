import Foundation
import SwiftUI
#if os(iOS)
import UIKit
#else
import AppKit
#endif

@MainActor
public enum iAFont: String, CaseIterable {
    case mono = "Mono"
    case duo = "Duo"
    case quattro = "Quattro"
    
    public var fileName: String {
        switch self {
        case .mono:
            return "iAWriterMonoV-Text"
        case .duo:
            return "iAWriterDuoV-Text"
        case .quattro:
            return "iAWriterQuattroV-Text"
        }
    }
    
    private var preferences: Preferences { Preferences.shared }
    
    public func attributes(forSize size: Double, color: Color) -> [NSAttributedString.Key : Any] {
        let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        var kern = 0.0
        
#if os(iOS)
        let foregroundColor = UIColor(color)
        let font = UIFont(name: fileName, size: size)!
#else
        let foregroundColor = NSColor(color)
        let font = NSFont(name: fileName, size: size)!
#endif
        
        switch self {
        case .mono:
            paragraphStyle.lineHeightMultiple = 1.35
            kern = 0.55
        case .duo:
            paragraphStyle.lineHeightMultiple = 1.35
            kern = 0.55
        case .quattro:
            paragraphStyle.lineHeightMultiple = 1.26
            kern = 0.05
        }
        
        return [
            .paragraphStyle: paragraphStyle,
            .font: font,
            .foregroundColor: foregroundColor,
            .kern: kern,
        ]
    }
}
