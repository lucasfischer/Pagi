import SwiftUI

struct ListScreen: View {
    
    @Bindable var viewModel: ViewModel
    @ObservedObject var store: Store
    
    @State private var isImportPresented = false
    @State private var isSettingsPresented = false
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
                SettingsView(storageURL: viewModel.storageURL)
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
                    showPaywall()
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
                            await viewModel.open(url)
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
    
    @ViewBuilder
    func EmptyView() -> some View {
        VStack(spacing: 16) {
            Text("Your morning pages will appear here.")
                .foregroundStyle(preferences.theme.colors.foregroundLight)
            
            Button("Start now") {
                Task {
                    await viewModel.newFile()
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .font(.custom(preferences.font.fileName, size: 16))
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
                                    await viewModel.open(file: file)
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
            .overlay {
                if viewModel.files.isEmpty {
                    EmptyView()
                        .transition(.opacity)
                }
            }
            .listStyle(.plain)
            .background(preferences.theme.colors.background.ignoresSafeArea())
            .scrollContentBackground(.hidden)
            .toolbarTitleDisplayMode(.inline)
            .toolbar {
                Toolbar()
            }
            .navigationDestination(item: $viewModel.editorViewModel) { viewModel in
                EditorView(viewModel: viewModel, storageURL: self.viewModel.storageURL)
                    .navigationBarBackButtonHidden()
            }
            .overlay {
                FloatingPlusButton(color: preferences.theme.colors.accent) {
                    if shouldShowPaywall {
                        showPaywall()
                    } else {
                        Task {
                            await viewModel.newFile()
                        }
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
        .onChange(of: viewModel.editorViewModel) {
            Task { await viewModel.loadFiles() }
        }
        .onOpenURL { url in
            Task { await viewModel.open(url) }
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

#Preview {
    ListScreen(
        viewModel: .mock,
        store: Store()
    )
}
