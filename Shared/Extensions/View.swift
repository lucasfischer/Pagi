//
//  View.swift
//  Pagi (iOS)
//
//  Created by Lucas Fischer on 10.12.22.
//

import SwiftUI

extension View {
    
    @available(macOS 12.0, *)
    func setPersistentSystemOverlays(_ visibility: Visibility) -> some View {
        if #available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *) {
            return self.persistentSystemOverlays(visibility)
        } else {
            return self
        }
    }
}

struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: Double = .zero
    static func reduce(value: inout Double, nextValue: () -> Double) {}
}

extension View {
    
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

extension View {
    
    func textSelectionEnabled() -> some View {
        if #available(iOS 15, macOS 12.0, *) {
            return self.textSelection(.enabled)
        } else {
            return self
        }
    }
    
}
