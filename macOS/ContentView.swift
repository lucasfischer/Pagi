import SwiftUI
import PagiKit

struct ContentView: View {
    @Binding var document: PagiDocument
    @ObservedObject var store: Store
    
    @ObservedObject var preferences = Preferences.shared
    @StateObject var viewModel = EditorViewModel()
    @State private var isPaywallPresented = false
    @State private var didAppear = false
    @State private var isPointerHovering = false
    
    @Environment(\.openWindow) private var openWindow
    
    private func onAppear() async {
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
        
        didAppear = true
    }
    
    @ViewBuilder private func ToolbarWrapper(content: () -> some View) -> some View {
        ZStack {
            if #available(macOS 15.0, *) {
                content()
                    .toolbarVisibility(viewModel.shouldHideToolbar && !isPointerHovering ? .hidden : .visible, for: .windowToolbar)
                    .onContinuousHover { phase in
                        switch phase {
                            case .active(let location):
                                if location.y <= 16 && location.y >= 0 {
                                    isPointerHovering = true
                                    viewModel.shouldHideToolbar = false
                                } else {
                                    isPointerHovering = false
                                }
                            case .ended:
                                isPointerHovering = false
                        }
                    }
            } else {
                content()
            }
        }
    }
    
    var body: some View {
        ToolbarWrapper {
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
            .ignoresSafeArea()
            .background(Color.background)
        }
        .toolbar {
            if !store.isUnlocked && didAppear {
                Button("Purchase Pagi") {
                    Haptics.buttonTap()
                    isPaywallPresented.toggle()
                }
            }
        }
        .sheet(isPresented: $isPaywallPresented) {
            PaywallScreen(store: store)
        }
        .id(store.isUnlocked)
        .task(onAppear)
    }
}

#Preview {
    ContentView(document: .constant(PagiDocument()), store: Store())
}
