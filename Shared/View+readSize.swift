//
//  View+readSize.swift
//  Pagi
//
//  Created by Lucas Fischer on 11.03.23.
//

import SwiftUI

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
