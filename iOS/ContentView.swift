import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store
    @State private var viewModel = ListScreenViewModel()
    
    @State private var isPresented: Bool = true
    var body: some View {
        ListScreen(viewModel: viewModel, store: store)
            .sheet(isPresented: $viewModel.isPaywallPresented) {
                PaywallScreen(store: store)
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
            }
            .task {
                await store.refreshPurchasedProducts()
            }
    }
}

#Preview {
    ContentView(store: .init())
}
