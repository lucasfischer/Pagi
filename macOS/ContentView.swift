//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

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
            
            Editor(text: $document.text, viewModel: viewModel)
        }
        .sheet(isPresented: $isPaywallPresented) {
            PaywallScreen(store: store)
        }
        .task {
            await store.refreshPurchasedProducts()
            
            let isTrialActive: Bool
            if let onBoardingCompletedAt = preferences.onBoardingCompletedAt {
                let date = Date(timeIntervalSinceReferenceDate: onBoardingCompletedAt)
                print(date.formatted())
                if Calendar.current.date(byAdding: .day, value: Configuration.freeDays, to: date)! > .now {
                    isTrialActive = true
                } else {
                    isTrialActive = false
                }
            } else {
                isTrialActive = true
            }
            if !store.isEntitled && !isTrialActive {
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
