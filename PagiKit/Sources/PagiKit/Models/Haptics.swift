import SwiftUI

@MainActor
public enum Haptics {
    
    @AppStorage("haptics") static private var isHapticsEnabled = true
    
    public static func selectionChanged() {
        if isHapticsEnabled {
#if canImport(UIKit)
            UISelectionFeedbackGenerator().selectionChanged()
#else
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.generic, performanceTime: .default)
#endif
        }
    }
    
    public static func impactOccurred(_ style: ImpactFeedbackStyle) {
        if isHapticsEnabled {
#if canImport(UIKit)
            UIImpactFeedbackGenerator(style: style.nativeStyle).impactOccurred()
#else
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.generic, performanceTime: .default)
#endif
        }
    }
    
    public static func notificationOccurred(_ type: NotificationFeedbackType) {
        if isHapticsEnabled {
#if canImport(UIKit)
            UINotificationFeedbackGenerator().notificationOccurred(type.nativeType)
#else
            let performer = NSHapticFeedbackManager.defaultPerformer
            performer.perform(.generic, performanceTime: .default)
#endif
        }
        
    }
    
    public static func buttonTap() {
        impactOccurred(.soft)
    }
    
}

extension Haptics {
    
    public enum ImpactFeedbackStyle {
        case heavy, light, medium, rigid, soft
        
#if canImport(UIKit)
        var nativeStyle: UIImpactFeedbackGenerator.FeedbackStyle {
            switch self {
                case .heavy: return .heavy
                case .light: return .light
                case .medium: return .medium
                case .rigid: return .rigid
                case .soft: return .soft
            }
        }
#endif
    }
    
    public enum NotificationFeedbackType {
        case error, success, warning
        
#if canImport(UIKit)
        var nativeType: UINotificationFeedbackGenerator.FeedbackType {
            switch self {
                case .error: return .error
                case .success: return .success
                case .warning: return .warning
            }
        }
#endif
    }
    
}
