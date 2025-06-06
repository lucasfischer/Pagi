import SwiftUI
import PagiKit

@MainActor @Observable
final class ViewModel {
    
    private let storageLocationProvider: StorageLocationProvider
    private let listFileManager: ListFileManager
    private var fileObserver: FileObserver?
    
    private var loadTask: Task<Void, Never>?
    
    public var isPaywallPresented = false
    public var files: Loadable<[File]> = .notRequested
    public var error: Error?
    public var editorViewModel: EditorView.ViewModel?
    
    public init(storageLocationProvider: StorageLocationProvider, listFileManager: ListFileManager) {
        self.storageLocationProvider = storageLocationProvider
        self.listFileManager = listFileManager
    }
    
    public var storageURL: URL? {
        storageLocationProvider.storageURL
    }
    
    public func startObserver() {
        let observer = FileObserver(storageLocationProvider: storageLocationProvider) {
            Task { await self.loadFiles() }
        }
        NSFileCoordinator.addFilePresenter(observer)
        self.fileObserver = observer
    }
    
    private func startLoadFilesTask() async {
        files = .isLoading(last: nil)
        do {
            let files = try await listFileManager.loadFiles()
            self.files = .loaded(files)
        } catch {
            self.error = error
            self.files = .failed(error)
        }
    }
    
    public func loadFiles() async {
        loadTask?.cancel()
        loadTask = Task {
            await startLoadFilesTask()
        }
        await loadTask?.value
    }
    
    public func remove(file: File) async {
        do {
            try await listFileManager.remove(file: file)
            if var files = files.value, let index = files.firstIndex(of: file) {
                files.remove(at: index)
                self.files = .loaded(files)
            }
        } catch {
            self.error = error
            Haptics.notificationOccurred(.error)
        }
    }
    
    public func newFile() async {
        let urlForToday = storageURL?
            .appendingPathComponent(
                Date.now.formatted(Date.dateFormatStyle),
                conformingTo: Preferences.shared.exportType.type
            )
        
        if let url = urlForToday {
            let text = try? await CloudStorage.shared.read(from: url)
            self.editorViewModel = .init(url: url, text: text ?? "")
        }
    }
    
    public func open(_ url: URL) async {
        do {
            if let scheme = url.scheme, scheme == "pagi" {
                if url.lastPathComponent == "onboarding" {
                    Preferences.shared.isOnboardingPresented = true
                }
                return
            }
            
            let _ = url.startAccessingSecurityScopedResource()
            let text = try await CloudStorage.shared.read(from: url)
            url.stopAccessingSecurityScopedResource()
            editorViewModel = .init(url: url, text: text)
        } catch {
            Haptics.notificationOccurred(.error)
            self.error = error
        }
    }
    
    public func open(file: File) async {
        var file = file
        file.text = (try? await CloudStorage.shared.read(from: file.url)) ?? file.text
        editorViewModel = .init(url: file.url, text: file.text)
    }
    
    public func copyToPasteboard(file: File) async {
        do {
            let text = try await CloudStorage.shared.read(from: file.url)
            UIPasteboard.general.string = text
        } catch {
            self.error = error
            Haptics.notificationOccurred(.error)
        }
    }
    
}

extension ViewModel {
    
    final class FileObserver: NSObject, NSFilePresenter {
        
        private let onDidChange: () -> Void
        private let storageLocationProvider: StorageLocationProvider
        
        init(storageLocationProvider: StorageLocationProvider, onDidChange: @escaping () -> Void) {
            self.onDidChange = onDidChange
            self.storageLocationProvider = storageLocationProvider
        }
        
        nonisolated var presentedItemURL: URL? {
            storageLocationProvider.storageURL
        }
        
        nonisolated var presentedItemOperationQueue: OperationQueue {
            .main
        }
        
        nonisolated func presentedItemDidChange() {
            onDidChange()
        }
        
    }
}

extension ViewModel {
    static let mock = ViewModel(
        storageLocationProvider: MockStorageLocationProvider(),
        listFileManager: MockListFileManager(storageLocationProvider: MockStorageLocationProvider())
    )
}
