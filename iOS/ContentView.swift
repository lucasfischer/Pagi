import SwiftUI

struct ContentView: View {
    @ObservedObject var preferences = Preferences.shared
    @ObservedObject var store: Store
    @Bindable var viewModel: ViewModel
    
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
        .errorAlert(error: $viewModel.error)
        .animation(.smooth, value: preferences.isOnboardingPresented)
        .task {
            viewModel.startObserver()
            await store.refreshPurchasedProducts()
            await viewModel.loadFiles()
            if let files = viewModel.files.value, files.isEmpty {
                await viewModel.newFile()
            }
        }
    }
}

#Preview {
    ContentView(store: .init(), viewModel: ViewModel(
        storageLocationProvider: MockStorageLocationProvider(),
        listFileManager: MockListFileManager(storageLocationProvider: MockStorageLocationProvider()))
    )
}
