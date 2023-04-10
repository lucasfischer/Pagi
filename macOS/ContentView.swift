//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct ContentView: View {
    @Binding var document: PagiDocument
    @StateObject var viewModel = EditorViewModel()
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            Editor(text: $document.text, shouldHideToolbar: .constant(false), viewModel: viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PagiDocument()))
    }
}
