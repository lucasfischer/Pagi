import SwiftUI

struct ContentView: View {
    @ObservedObject var preferences = Preferences.shared
    @ObservedObject var store: Store
    @State private var viewModel = ListScreenViewModel()
    
    @State private var isPresented: Bool = true
    var body: some View {
        Group {
            if preferences.isOnboardingPresented {
                OnboardingScreen(isPresented: $preferences.isOnboardingPresented)
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
        .animation(.smooth, value: preferences.isOnboardingPresented)
        .task {
            await store.refreshPurchasedProducts()
            await viewModel.loadFiles()
        }
    }
}

#Preview {
    ContentView(store: .init())
}
