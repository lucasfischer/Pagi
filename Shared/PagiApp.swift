import SwiftUI
import PagiKit

@main
struct PagiApp: App {
    @Environment(\.openURL) var openURL
    
    @StateObject private var preferences = Preferences.shared
    @StateObject private var store = Store()
    
#if os(iOS)
    @State private var viewModel = ViewModel(
        storageLocationProvider: RealStorageLocationProvider(),
        listFileManager: RealListFileManager(storageLocationProvider: RealStorageLocationProvider())
    )
#endif
    
    var body: some Scene {
#if os(macOS)
        
        DocumentGroup(newDocument: PagiDocument()) { file in
            ContentView(document: file.$document, store: store)
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        .windowToolbarStyle(.unifiedCompact)
        .commands {
            FindCommands()
            FontCommands(font: $preferences.font, fontSize: $preferences.fontSize)
            ViewCommands(
                wordCount: $preferences.wordCount,
                progressBar: $preferences.progressBar
            )
            FocusCommands(
                focusMode: $preferences.isFocusModeEnabled,
                focusType: $preferences.focusType
            )
            HelpCommands()
            
            CommandGroup(replacing: .newItem, addition: {
                Button("New") {
                    NSDocumentController.shared.newDocument(nil)
                }
                .keyboardShortcut("n", modifiers: .command)
            })
            
            CommandGroup(replacing: .appInfo, addition: {
                Button("About Pagi") {
                    if let url = URL(string: "pagi://about") {
                        openURL(url)
                    }
                }
            })
        }
        
        Settings {
            SettingsView()
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        
        WindowGroup("About Pagi") {
            AboutView()
                .preferredColorScheme(preferences.theme.colorScheme)
                .handlesExternalEvents(preferring: Set(arrayLiteral: "about"), allowing: Set(arrayLiteral: "about"))
        }
        .windowStyle(HiddenTitleBarWindowStyle())
        .windowResizability(.contentSize)
        
        Window("Onboarding", id: "onboarding") {
            OnboardingScreen(store: store, isPresented: $preferences.isOnboardingPresented)
                .frame(width: 1024, height: 600)
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        .commandsRemoved()
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        
#elseif os(iOS)
        
        WindowGroup {
            ContentView(store: store, viewModel: viewModel)
                .background(preferences.theme.colors.background.ignoresSafeArea())
                .tint(preferences.theme.colors.accent)
                .preferredColorScheme(preferences.theme.colorScheme)
        }
        .commands {
            FontCommands(font: $preferences.font, fontSize: $preferences.fontSize)
            FocusCommands(
                focusMode: $preferences.isFocusModeEnabled,
                focusType: $preferences.focusType
            )
            ViewCommands(viewModel: viewModel, wordCount: $preferences.wordCount, progressBar: $preferences.progressBar)
        }
        
#endif
    }
}
