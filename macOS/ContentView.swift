//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PagiDocument
    @ObservedObject var preferences = Preferences.shared
    @StateObject var viewModel = EditorViewModel()
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            Editor(text: $document.text, viewModel: viewModel)
        }
        .onAppear {
            if preferences.isOnboardingPresented {
                openWindow(id: "onboarding")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PagiDocument()))
    }
}
