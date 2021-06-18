//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PagiDocument
    @AppStorage("theme") private var theme = Theme.system
    @Environment(\.colorScheme) var colorScheme
    
    var userColorScheme: ColorScheme {
        switch theme {
        case .system:
            return colorScheme
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
    
    var body: some View {
        ZStack {
            Color.background
            
            Editor(text: $document.text)
                .environment(\.colorScheme, userColorScheme)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PagiDocument()))
    }
}
