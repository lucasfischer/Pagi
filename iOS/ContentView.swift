import SwiftUI

struct ContentView: View {
    @ObservedObject var store: Store
    @State private var viewModel = ListScreenViewModel()
    @State private var isOnboardingPresented: Bool = true
    
    @State private var isPresented: Bool = true
    var body: some View {
        Group {
            if isOnboardingPresented {
                OnboardingScreen(isPresented: $isOnboardingPresented)
                    .transition(.opacity)
            } else {
                ListScreen(viewModel: viewModel, store: store)
                    .sheet(isPresented: $viewModel.isPaywallPresented) {
                        PaywallScreen(store: store)
                            .presentationDragIndicator(.visible)
                            .presentationCornerRadius(24)
                    }
            }
        }
        .animation(.smooth, value: isOnboardingPresented)
        .task {
            await store.refreshPurchasedProducts()
            await viewModel.loadFiles()
        }
    }
}

#Preview {
    ContentView(store: .init())
}
