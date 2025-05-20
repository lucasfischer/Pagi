import SwiftUI

extension ContentView {
    
    @MainActor
    class ViewModel: ObservableObject {
        @AppStorage("text") var text = ""
        @AppStorage("theme") var theme = Theme.system
        @AppStorage("lastOpenedDate") var lastOpenedDate: String?
        @AppStorage("isFileExported") var isFileExported = false
        
        @Published var showExport = false
        @Published var showSettings = false {
            /// Hide Keyboard when opening/closing the settings to prevent `.popover()` related glitch.
            didSet {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        @Published var shareItem: ShareItem?
        @Published var showClearNotification = false
        @Published var toolbarHeight: Double = .zero
        @Published var isKeyboardVisible = false
        
        var editorViewModel = EditorViewModel()
        
        var exportType = Preferences.shared.exportType
        
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad
        
        var shouldReset = false
        
        let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "YYYY-MM-dd"
            return formatter
        }()
        
        var currentDateString: String {
            dateFormatter.string(from: Date())
        }
        
        func onAppear() {
            if let date = lastOpenedDate,
               let lastDate = dateFormatter.date(from: date),
               !Calendar.current.isDateInToday(lastDate) && !text.isEmpty {
                onShowClearNotification()
            }
        }
        
        func getToolbarOffset(_ geometry: GeometryProxy) -> CGSize {
            var height = editorViewModel.shouldHideToolbar || isKeyboardVisible ? toolbarHeight + geometry.safeAreaInsets.bottom : 0
            if isiPad {
                height = editorViewModel.shouldHideToolbar ? 0 - toolbarHeight + geometry.safeAreaInsets.top : 0
            }
            
            return CGSize(width: 0, height: height)
        }
        
        func onTextUpdate(_ text: String) {
            lastOpenedDate = dateFormatter.string(from: Date())
            isFileExported = false
        }
        
        func onButtonTap() {
            Haptics.impactOccurred(.rigid)
        }
        
        func onShowClearNotification() {
            onButtonTap()
            showClearNotification.toggle()
        }
        
        func onShowSettings() {
            onButtonTap()
            showSettings.toggle()
        }
        
        func onShowExport(type: FileType = Preferences.shared.exportType) {
            exportType = type
            onButtonTap()
            showExport.toggle()
        }
        
        func onShowShareSheet(type: ShareSheetType = .file(Preferences.shared.exportType)) {
            onButtonTap()
            
            switch type {
                case .file(let type):
                    // Create temporary file to share
                    do {
                        let url = FileManager.default.temporaryDirectory.appendingPathComponent(currentDateString, conformingTo: type.type)
                        let data = Data(text.utf8)
                        try data.write(to: url)
                        shareItem = .url(url)
                    } catch {
                        print(error)
                    }
                case .text:
                    shareItem = .text(text)
            }
        }
        
        func onCopy() {
            onButtonTap()
            UIPasteboard.general.string = text
        }
        
        func onFileExported(_ result: Result<URL, Error>) {
            switch result {
                case .success:
                    if shouldReset {
                        reset()
                    }
                    showClearNotification = false
                    showExport = false
                    isFileExported = true
                default:
                    break
            }
        }
        
        func reset() {
            self.text = ""
            self.lastOpenedDate = nil
            self.editorViewModel.resetTimer()
        }
        
    }
}

extension ContentView {
    
    enum ShareSheetType {
        case text, file(FileType)
    }
    
    enum ShareItem: Identifiable {
        case text(String)
        case url(URL)
        
        var id: String {
            switch self {
                case .text(let string):
                    string
                case .url(let url):
                    url.absoluteString
            }
        }
    }
    
}
