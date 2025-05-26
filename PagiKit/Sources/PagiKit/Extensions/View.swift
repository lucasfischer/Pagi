import SwiftUI

public extension View {
    
    @available(macOS 12.0, *)
    func setPersistentSystemOverlays(_ visibility: Visibility) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return self.persistentSystemOverlays(visibility)
        } else {
            return self
        }
    }
}

public struct HeightPreferenceKey: PreferenceKey {
    static public let defaultValue: Double = .zero
    static public func reduce(value: inout Double, nextValue: () -> Double) {}
}

public extension View {
    
    func readSize(onChange: @escaping (Double) -> Void) -> some View {
        background(
            GeometryReader { geometryProxy in
                Color.clear
                    .preference(key: HeightPreferenceKey.self, value: geometryProxy.size.height)
            }
        )
        .onPreferenceChange(HeightPreferenceKey.self, perform: onChange)
    }
    
}

public extension View {
    
    func textSelectionEnabled() -> some View {
        if #available(iOS 15, macOS 12.0, *) {
            return self.textSelection(.enabled)
        } else {
            return self
        }
    }
    
}
