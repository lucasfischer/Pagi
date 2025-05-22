import SwiftUI

struct ListScreen: View {
    
    var viewModel: ListScreenModel
    @ObservedObject var store: Store
    
    @State private var isImportPresented = false
    @State private var isSettingsPresented = false
    @State private var editorViewModel: EditorView.ViewModel?
    @State private var error: Error?
    @ObservedObject private var preferences = Preferences.shared
    
    @Environment(\.scenePhase) var scenePhase: ScenePhase
    
    private var dates: [(key: Date, value: [File])] {
        let calendar = Calendar.current
        return Dictionary(
            grouping: viewModel.files,
            by: {
                var date = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: $0.date ?? .now)!
                date = calendar.date(bySetting: .day, value: 1, of: date)!
                return date
            }
        )
        .sorted(by: { a, b in a.key > b.key })
    }
    
    private var shouldShowPaywall: Bool {
        viewModel.files.count >= Configuration.freeDays && !store.isEntitled
    }
    
    private func showPaywall() {
        viewModel.isPaywallPresented = true
    }
    
    func newFile() {
        let urlForToday = viewModel.containerURL?
            .appendingPathComponent(
                Date.now.formatted(.iso8601.year().month().day()),
                conformingTo: Preferences.shared.exportType.type
            )
        
        Task {
            if let url = urlForToday {
                let text = try? await CloudStorage.shared.read(from: url)
                self.editorViewModel = .init(url: url, text: text ?? "")
            }
        }
    }
    
    func open(_ url: URL) async {
        do {
            let _ = url.startAccessingSecurityScopedResource()
            let text = try await CloudStorage.shared.read(from: url)
            url.stopAccessingSecurityScopedResource()
            editorViewModel = .init(url: url, text: text)
        } catch {
            Haptics.notificationOccurred(.error)
            self.error = error
        }
    }
    
    func open(file: File) async {
        var file = file
        file.text = (try? await CloudStorage.shared.read(from: file.url)) ?? file.text
        editorViewModel = .init(url: file.url, text: file.text)
    }
    
    func removeRows(at offsets: IndexSet) {
        for offset in offsets {
            let file = viewModel.files[offset]
            Task {
                await remove(file: file)
            }
        }
    }
    
    func remove(file: File) async {
        do {
            try await viewModel.remove(file: file)
        } catch {
            self.error = error
            Haptics.notificationOccurred(.error)
        }
    }
    
    @ToolbarContentBuilder
    func Toolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button("Settings", systemImage: "gear") {
                Haptics.buttonTap()
                isSettingsPresented.toggle()
            }
            .popover(isPresented: $isSettingsPresented) {
                SettingsView()
                    .frame(
                        minWidth: 320,
                        idealWidth: 400,
                        idealHeight: 700,
                        alignment: .top
                    )
                    .preferredColorScheme(preferences.theme.colorScheme)
            }
            
            if !store.isEntitled {
                Button {
                    Haptics.buttonTap()
                    viewModel.isPaywallPresented.toggle()
                } label: {
                    Text("Purchase Pagi")
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(preferences.theme.colors.accent, lineWidth: 2)
                        }
                }
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Button("Open") {
                Haptics.buttonTap()
                if shouldShowPaywall {
                    showPaywall()
                } else {
                    isImportPresented.toggle()
                }
            }
            .fileImporter(isPresented: $isImportPresented, allowedContentTypes: [.plainText, .markdown]) { result in
                switch result {
                    case .success(let url):
                        Task {
                            await open(url)
                        }
                    case .failure(let error):
                        print(error)
                }
            }
        }
    }
    
    @ViewBuilder
    func ContextMenu(for file: File) -> some View {
        Section {
            ShareLink(item: file.url) {
                Label("Share", systemImage: "square.and.arrow.up")
            }
            Button("Copy", systemImage: "doc.on.doc") {
                Haptics.notificationOccurred(.success)
                Task {
                    do {
                        let text = try await CloudStorage.shared.read(from: file.url)
                        UIPasteboard.general.string = text
                    } catch {
                        self.error = error
                        Haptics.notificationOccurred(.error)
                    }
                }
            }
        }
        
        Button("Delete", systemImage: "trash", role: .destructive) {
            Haptics.buttonTap()
            Task {
                await remove(file: file)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dates, id: \.key) { (date, files) in
                    Section {
                        ForEach(files, id: \.self) { file in
                            Button {
                                Haptics.buttonTap()
                                Task {
                                    await open(file: file)
                                }
                            } label: {
                                Text(file.displayName)
                                    .foregroundStyle(Preferences.shared.theme.colors.foregroundLight)
                            }
                            .contextMenu {
                                ContextMenu(for: file)
                                    .tint(preferences.theme.colors.accent)
                            }
                        }
                        .onDelete(perform: removeRows)
                    } header: {
                        Text(date.formatted(.dateTime.year().month()))
                            .foregroundStyle(preferences.theme.colors.foreground)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listStyle(.plain)
            .background(preferences.theme.colors.background.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Toolbar()
            }
            .navigationDestination(item: $editorViewModel) { viewModel in
                EditorView(viewModel: viewModel)
                    .navigationBarBackButtonHidden()
            }
            .overlay {
                FloatingPlusButton(color: preferences.theme.colors.accent) {
                    if shouldShowPaywall {
                        showPaywall()
                    } else {
                        newFile()
                    }
                }
            }
        }
        .errorAlert(error: $error)
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task { await viewModel.loadFiles() }
            }
        }
        .scrollContentBackground(.hidden)
        .animation(.default, value: viewModel.files)
        .task {
            await viewModel.loadFiles()
        }
        .onChange(of: editorViewModel) {
            Task { await viewModel.loadFiles() }
        }
        .onOpenURL { url in
            Task { await open(url) }
        }
    }
}

struct File: Identifiable, Hashable, Observable {
    var id: String { url.absoluteString }
    var url: URL
    var text: String
    
    var fileNameWithoutExtension: String {
        url.deletingPathExtension().lastPathComponent
    }
    
    var date: Date? {
        if let date = try? Date.dateFormatStyle.parse(fileNameWithoutExtension) {
            return date
        } else {
            return nil
        }
    }
    
    var displayName: String {
        if let date {
            date.formatted(.dateTime.day().weekday(.wide))
        } else {
            fileNameWithoutExtension
        }
    }
}

@MainActor
protocol ListScreenModel: NSObject {
    var isPaywallPresented: Bool { get set }
    var files: [File] { get }
    var containerURL: URL? { get }
    func loadFiles() async
    func remove(file: File) async throws
}

@Observable
class ListScreenViewModel: NSObject, ListScreenModel {
    
    override init() {
        super.init()
        NSFileCoordinator.addFilePresenter(self)
    }
    
    deinit {
        NSFileCoordinator.removeFilePresenter(self)
    }
    
    public var isPaywallPresented = false
    
    private(set) var files: [File] = []
    
    private var loadTask: Task<Void, Never>?
    
    var containerURL: URL? {
        var containerURL: URL?
        
        if let iCloudContainerURL = FileManager.default.iCloudContainerURL {
            containerURL = iCloudContainerURL
        } else {
            containerURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        }
        
        return containerURL
    }
    
    func startLoadFilesTask() async {
        guard let containerURL else {
            return
        }
        
        do {
            let urls = try await CloudStorage.shared.listFiles(in: containerURL)
            var files = [File]()
            for url in urls.sorted(by: { $0.lastPathComponent.localizedStandardCompare($1.lastPathComponent) == .orderedDescending }) {
                if Task.isCancelled {
                    return
                }
                let text = "" // try await CloudStorage.shared.readFromCloud(fileURL: url)
                files.append(
                    File(url: url, text: text)
                )
            }
            self.files = files
        } catch {
            print(error)
        }
    }
    
    func loadFiles() async {
        loadTask?.cancel()
        loadTask = Task {
            await startLoadFilesTask()
        }
    }
    
    func remove(file: File) async throws {
        try await CloudStorage.shared.delete(file.url)
        if let index = files.firstIndex(of: file) {
            files.remove(at: index)
        }
    }
}

extension ListScreenViewModel: NSFilePresenter {
    
    nonisolated var presentedItemURL: URL? {
        FileManager.default.url(forUbiquityContainerIdentifier: nil)?
            .appendingPathComponent("Documents")
    }
    
    nonisolated var presentedItemOperationQueue: OperationQueue {
        .main
    }
    
    nonisolated func presentedItemDidChange() {
        Task {
            await loadFiles()
        }
    }
    
}

@Observable
class MockScreenViewModel: NSObject, ListScreenModel {
    public var isPaywallPresented = false
    
    private(set) var files: [File] = []
    
    var containerURL: URL? {
        FileManager.default.temporaryDirectory
    }
    
    override init() {
        super.init()
        files = Array(1...100).map { i in
            let date = Calendar.current.date(byAdding: .day, value: -i, to: .now)!
            return File(url: containerURL!.appendingPathComponent(date.formatted(.iso8601.year().month().day()), conformingTo: .plainText), text: "Hello, World!")
        }
    }
    
    func loadFiles() async {
        
    }
    
    func remove(file: File) async {
        if let index = files.firstIndex(of: file) {
            files.remove(at: index)
        }
    }
}

#Preview {
    ListScreen(
        viewModel: MockScreenViewModel(),
        store: Store()
    )
}
