import SwiftUI
import UIKit
import PagiKit

struct EditorView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var editorViewModel: EditorViewModel // To update View on EditorViewModel changes
    
    @Environment(\.dismiss) private var dismiss
    
    let storageURL: URL?
    
    public init(viewModel: ViewModel, storageURL: URL?) {
        self.viewModel = viewModel
        self._editorViewModel = ObservedObject(initialValue: viewModel.editorViewModel)
        self.storageURL = storageURL
    }
    
    @ViewBuilder
    func ShareSheetWrapper(_ item: ShareItem) -> some View {
        switch item {
            case .text(let text):
                ShareSheet(activityItems: [text])
                    .ignoresSafeArea()
            case .url(let url):
                ShareSheet(activityItems: [url])
                    .ignoresSafeArea()
        }
    }
    
    @ViewBuilder
    func ShareContextMenu() -> some View {
        Button(action: { viewModel.onShowShareSheet(type: .text) }) {
            Label("Share as Text", systemImage: "square.and.arrow.down")
        }
        Section {
            Button(action: { viewModel.onShowShareSheet(type: .file(.text)) }) {
                Label("Share as Plain Text File", systemImage: "square.and.arrow.down")
            }
            Button(action: { viewModel.onShowShareSheet(type: .file(.markdown)) }) {
                Label("Share as Markdown File", systemImage: "square.and.arrow.down")
            }
        }
    }
    
    @ViewBuilder
    func iPhoneFooter(_ geometry: GeometryProxy) -> some View {
        HStack {
            Button("Back", systemImage: "chevron.left") {
                viewModel.onButtonTap()
                Task {
                    await viewModel.save(delay: 0)
                    dismiss()
                }
            }
            .font(.title2)
            .labelStyle(.iconOnly)
            
            Spacer()
            
            Button(action: { viewModel.onShowSettings() }) {
                Label("Settings", systemImage: "gear")
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .popover(isPresented: $viewModel.showSettings) {
                SettingsView(storageURL: storageURL)
                    .frame(
                        minWidth: 320,
                        idealWidth: 400,
                        idealHeight: 700,
                        alignment: .top
                    )
                    .preferredColorScheme(viewModel.theme.colorScheme)
            }
            
            Spacer()
            
            Group {
                Button(action: { viewModel.onCopy() }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
                
                Spacer()
                
                Button(action: { viewModel.onShowExport() }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                .contextMenu {
                    Button(action: { viewModel.onShowExport(type: .text) }) {
                        Label("Save as Plain Text", systemImage: "square.and.arrow.down")
                    }
                    Button(action: { viewModel.onShowExport(type: .markdown) }) {
                        Label("Save as Markdown", systemImage: "square.and.arrow.down")
                    }
                }
                
                Spacer()
                
                Button(action: { viewModel.onShowShareSheet() }) {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                .contextMenu {
                    ShareContextMenu()
                }
                .sheet(item: $viewModel.shareItem) { item in
                    ShareSheetWrapper(item)
                }
            }
            .disabled(viewModel.text.isEmpty)
            .labelStyle(.iconOnly)
            .font(.title2)
            
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Material.ultraThin)
        .overlay(alignment: .top) {
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.black.opacity(0.1))
        }
        .offset(viewModel.getToolbarOffset(geometry))
        .animation(.spring(), value: viewModel.editorViewModel.shouldHideToolbar)
        .readSize { height in
            viewModel.toolbarHeight = height
        }
    }
    
    @ToolbarContentBuilder
    func iPadToolbar() -> some ToolbarContent {
        ToolbarItemGroup(placement: .navigation) {
            Button("Back", systemImage: "chevron.left") {
                viewModel.onButtonTap()
                Task {
                    await viewModel.save(delay: 0)
                    dismiss()
                }
            }
            
            Button(action: { viewModel.onShowSettings() }) {
                Label("Settings", systemImage: "gear")
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .popover(isPresented: $viewModel.showSettings) {
                SettingsView(storageURL: storageURL)
                    .frame(
                        minWidth: 320,
                        idealWidth: 400,
                        idealHeight: 700,
                        alignment: .top
                    )
                    .preferredColorScheme(viewModel.theme.colorScheme)
            }
        }
        
        if let date = viewModel.currentDate {
            ToolbarItem(placement: .principal) {
                Text(date, format: .dateTime.weekday().day().month().year())
                    .font(.headline)
            }
        }
        
        ToolbarItem(placement: .primaryAction) {
            Menu {
                Menu {
                    ShareContextMenu()
                } label: {
                    Label("Share", systemImage: "square.and.arrow.up")
                }
                Button(action: { viewModel.onShowExport() }) {
                    Label("Save", systemImage: "square.and.arrow.down")
                }
                Button(action: { viewModel.onCopy() }) {
                    Label("Copy", systemImage: "doc.on.doc")
                }
            } label: {
                Label("Share", systemImage: "square.and.arrow.up")
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .disabled(viewModel.text.isEmpty)
            .popover(item: $viewModel.shareItem) { item in
                ShareSheetWrapper(item)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Editor(text: $viewModel.text, viewModel: viewModel.editorViewModel)
                .ignoresSafeArea(.container, edges: .vertical)
                .safeAreaInset(edge: .bottom) {
                    if !viewModel.isiPad {
                        iPhoneFooter(geometry)
                    }
                }
        }
        .toolbar {
            if viewModel.isiPad {
                iPadToolbar()
            }
        }
        .toolbarVisibility(viewModel.editorViewModel.shouldHideToolbar || !viewModel.isiPad ? .hidden : .automatic, for: .navigationBar)
        .toolbarBackgroundVisibility(.visible, for: .navigationBar)
        .toolbarBackground(Material.ultraThin, for: .navigationBar)
        .animation(.smooth, value: viewModel.editorViewModel.shouldHideToolbar)
        .overlay(alignment: .top) {
            Group {
                if let date = viewModel.currentDate, !viewModel.isiPad && !viewModel.editorViewModel.shouldHideToolbar {
                    Text(date, format: .dateTime.weekday().day().month().year())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Preferences.shared.theme.colors.foregroundFaded)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Preferences.shared.theme.colors.background)
                        )
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
            .animation(.smooth, value: viewModel.editorViewModel.shouldHideToolbar)
        }
        .statusBarHidden(viewModel.editorViewModel.shouldHideToolbar)
        .setPersistentSystemOverlays(viewModel.editorViewModel.shouldHideToolbar ? .hidden : .automatic)
        .fileExporter(
            isPresented: $viewModel.showExport,
            document: PagiDocument(text: viewModel.text),
            contentType: viewModel.exportType.type,
            defaultFilename: viewModel.currentDateString,
            onCompletion: viewModel.onFileExported
        )
        .onChange(of: viewModel.text) {
            viewModel.onTextUpdate(viewModel.text)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { data in
            viewModel.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { data in
            viewModel.isKeyboardVisible = false
        }
    }
}

//struct EditorView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditorView(viewModel: EditorView.ViewModel())
//    }
//}
