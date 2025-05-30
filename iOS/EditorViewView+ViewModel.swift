import SwiftUI
import PagiKit

extension EditorView {
    
    @MainActor
    class ViewModel: NSObject, ObservableObject {
        let url: URL
        private let document: TextDocument
        
        init(url: URL, text: String) {
            let _ = url.startAccessingSecurityScopedResource()
            
            self.url = url
            self.document = TextDocument(fileURL: url)
            self.text = text
            super.init()
            
            NotificationCenter.default.addObserver(
                self,
                selector: #selector(documentStateChanged),
                name: UIDocument.stateChangedNotification,
                object: document
            )
        }
        
        deinit {
            url.stopAccessingSecurityScopedResource()
            NotificationCenter.default.removeObserver(self)
        }
        
        private var saveTask: Task<Void, Error>?
        
        @Published var text = ""
        @AppStorage("theme") var theme = Theme.system
        
        @Published var showExport = false
        @Published var showSettings = false {
            /// Hide Keyboard when opening/closing the settings to prevent `.popover()` related glitch.
            didSet {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        @Published var shareItem: ShareItem?
        @Published var toolbarHeight: Double = .zero
        @Published var isKeyboardVisible = false
        
        var editorViewModel = EditorViewModel()
        
        var exportType = Preferences.shared.exportType
        
        let isiPad = UIDevice.current.userInterfaceIdiom == .pad
        
        var currentDate: Date? {
            try? Date.dateFormatStyle.parse(currentDateString)
        }
        
        var currentDateString: String {
            url.deletingPathExtension().lastPathComponent
        }
        
        func onAppear() async {
            if (try? document.fileURL.checkResourceIsReachable()) == true {
                await document.open()
            } else {
                await document.save(to: document.fileURL, for: .forCreating)
            }
        }
        
        func getToolbarOffset(_ geometry: GeometryProxy) -> CGSize {
            let height = editorViewModel.shouldHideToolbar || isKeyboardVisible ? toolbarHeight + geometry.safeAreaInsets.bottom : 0
            return CGSize(width: 0, height: height)
        }
        
        func onButtonTap() {
            Haptics.impactOccurred(.rigid)
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
                    showExport = false
                default:
                    break
            }
        }
        
        func reset() {
            self.text = ""
            self.editorViewModel.resetTimer()
        }
        
    }
}

// MARK: Document Functions
extension EditorView.ViewModel {
    
    @objc private func documentStateChanged() {
        switch document.documentState {
            case .normal:
                text = document.text
            case .savingError:
                break
            case .inConflict:
                handleConflict()
            default:
                break
        }
    }
    
    private func handleConflict() {
        guard let versions = NSFileVersion.unresolvedConflictVersionsOfItem(at: document.fileURL) else {
            return
        }
        
        var latestVersion: NSFileVersion?
        for version in versions {
            if let modificationDate = version.modificationDate {
                if latestVersion == nil {
                    latestVersion = version
                } else if let latestVersionModificationDate = latestVersion?.modificationDate, latestVersionModificationDate < modificationDate {
                    latestVersion = version
                } else {
                    try? version.remove()
                }
            }
        }
        
        if let latestVersion,
           let versionModificationDate = latestVersion.modificationDate,
           let documentModificationDate = document.fileModificationDate,
           versionModificationDate > documentModificationDate {
            if let text = try? String(contentsOf: latestVersion.url, encoding: .utf8) {
                latestVersion.isResolved = true
                self.text = text
            }
        }
        
        do {
            try NSFileVersion.removeOtherVersionsOfItem(at: document.fileURL)
        } catch {
            print("Error removing conflict versions: \(error)")
        }
    }
    
    func onTextUpdate(_ text: String) {
        document.updateText(text)
    }
    
    func save() async {
        if FileManager.default.fileExists(atPath: document.fileURL.path()) {
            await document.save(to: url, for: .forOverwriting)
        } else {
            await document.save(to: url, for: .forCreating)
        }
    }
    
    func closeDocument() async {
        await document.close()
    }
    
}

extension EditorView {
    
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
