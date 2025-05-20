//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    @ObservedObject var editorViewModel: EditorViewModel // To update View on EditorViewModel changes
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        self._editorViewModel = ObservedObject(initialValue: viewModel.editorViewModel)
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
    func Header(_ geometry: GeometryProxy) -> some View {
        HStack(spacing: viewModel.isiPad ? 24 : nil) {
            Button(action: { viewModel.onShowSettings() }) {
                Label("Settings", systemImage: "gear")
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .popover(isPresented: $viewModel.showSettings) {
                SettingsView()
                    .frame(
                        minWidth: 320,
                        idealWidth: 400,
                        idealHeight: 700,
                        alignment: .top
                    )
                    .preferredColorScheme(viewModel.theme.colorScheme)
            }
            
            if !viewModel.isiPad {
                Spacer()
            }
            
            Button {
                viewModel.onShowClearNotification()
            } label: {
                Label("Clear Text", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .font(.title2)
            }
            .disabled(viewModel.text.isEmpty)
            
            Spacer()
            
            if viewModel.isiPad {
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
            } else {
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
            
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Material.ultraThin)
        .overlay(alignment: viewModel.isiPad ? .bottom : .top) {
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
    
    var body: some View {
        GeometryReader { geometry in
            Editor(text: $viewModel.text, viewModel: viewModel.editorViewModel)
                .ignoresSafeArea(.container, edges: .vertical)
                .safeAreaInset(edge: viewModel.isiPad ? .top : .bottom) {
                    Header(geometry)
                }
        }
        .id(viewModel.lastOpenedDate)
        .statusBarHidden(viewModel.editorViewModel.shouldHideToolbar)
        .setPersistentSystemOverlays(viewModel.editorViewModel.shouldHideToolbar ? .hidden : .automatic)
        .fileExporter(
            isPresented: $viewModel.showExport,
            document: PagiDocument(text: viewModel.text),
            contentType: viewModel.exportType.type,
            defaultFilename: viewModel.currentDateString,
            onCompletion: viewModel.onFileExported
        )
        .alert(
            "Do you want to clear your notes?",
            isPresented: $viewModel.showClearNotification,
            actions: {
                Button("Keep", role: .cancel) {
                    viewModel.showClearNotification = false
                }
                Button("Clear", role: .destructive) {
                    viewModel.showClearNotification = false
                    viewModel.reset()
                }
                if !viewModel.isFileExported {
                    Button("Export then clear") {
                        viewModel.showExport = true
                        viewModel.shouldReset = true
                    }
                }
            })
        .onChange(of: viewModel.text, perform: viewModel.onTextUpdate)
        .onAppear(perform: viewModel.onAppear)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.onAppear()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillShowNotification)) { data in
            viewModel.isKeyboardVisible = true
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardWillHideNotification)) { data in
            viewModel.isKeyboardVisible = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel())
    }
}
