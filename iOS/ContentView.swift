import SwiftUI

struct ContentView: View {
    var viewModel: EditorView.ViewModel
    
    var body: some View {
        EditorView(viewModel: viewModel)
    }
}

#Preview {
    ContentView(viewModel: .init())
}
