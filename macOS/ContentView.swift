import SwiftUI
import PagiKit

struct ContentView: View {
    @Binding var document: PagiDocument
    @ObservedObject var store: Store
    
    @ObservedObject var preferences = Preferences.shared
    @StateObject var viewModel = EditorViewModel()
    @State private var isPaywallPresented = false
    
    @Environment(\.openWindow) private var openWindow
    
    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            
            Editor(text: $document.text, viewModel: viewModel) {
                TextEditorView(
                    text: $document.text,
                    colors: preferences.theme.colors,
                    font: preferences.font,
                    size: preferences.fontSize,
                    isSpellCheckingEnabled: preferences.isSpellCheckingEnabled,
                    focusMode: $preferences.isFocusModeEnabled,
                    focusType: preferences.focusType,
                    shouldHideToolbar: $viewModel.shouldHideToolbar
                )
                .id("\(preferences.font.rawValue)\(preferences.fontSize)")
            }
        }
        .sheet(isPresented: $isPaywallPresented) {
            PaywallScreen(store: store)
        }
        .task {
            await store.refreshPurchasedProducts()
            
            let isTrialActive: Bool
            if let onBoardingCompletedAt = preferences.onBoardingCompletedAt {
                let date = Date(timeIntervalSinceReferenceDate: onBoardingCompletedAt)
                if Calendar.current.date(byAdding: .day, value: Configuration.freeDays, to: date)! > .now {
                    isTrialActive = true
                } else {
                    isTrialActive = false
                }
            } else {
                isTrialActive = true
            }
            if !store.isUnlocked && !isTrialActive {
                isPaywallPresented = true
            }
            
            if preferences.isOnboardingPresented {
                openWindow(id: "onboarding")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(document: .constant(PagiDocument()), store: Store())
    }
}
