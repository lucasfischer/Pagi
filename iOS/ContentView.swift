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
    
    @ViewBuilder
    func Header(_ geometry: GeometryProxy) -> some View {
        HStack {
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
            
            Spacer()
            
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
                    Button(action: { viewModel.onShowShareSheet() }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: { viewModel.onShowExport() }) {
                        Label("Save", systemImage: "square.and.arrow.down")
                    }
                    Button(action: { viewModel.onCopy() }) {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                } label: {
                    Button(action: { viewModel.onShowExport() }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                            .labelStyle(.iconOnly)
                            .font(.title2)
                    }
                }
                .disabled(viewModel.text.isEmpty)
                .popover(isPresented: $viewModel.showShareSheet) {
                    ShareSheet(activityItems: [viewModel.text])
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
                    
                    Spacer()
                    
                    Button(action: { viewModel.onShowShareSheet() }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    .popover(isPresented: $viewModel.showShareSheet) {
                        ShareSheet(activityItems: [viewModel.text])
                    }
                }
                .disabled(viewModel.text.isEmpty)
                .labelStyle(.iconOnly)
                .font(.title2)
            }
            
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Material.thin)
        .overlay(alignment: viewModel.isiPad ? .bottom : .top) {
            Rectangle()
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .foregroundColor(.black.opacity(0.1))
        }
        .offset(viewModel.getToolbarOffset(geometry))
        .animation(.spring(), value: viewModel.shouldHideToolbar)
        .readSize { height in
            viewModel.toolbarHeight = height
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            Editor(text: $viewModel.text, shouldHideToolbar: $viewModel.shouldHideToolbar)
                .ignoresSafeArea(.container, edges: .vertical)
                .safeAreaInset(edge: viewModel.isiPad ? .top : .bottom) {
                    Header(geometry)
                }
        }
        .id(viewModel.lastOpenedDate)
        .statusBarHidden(viewModel.shouldHideToolbar)
        .setPersistentSystemOverlays(viewModel.shouldHideToolbar ? .hidden : .automatic)
        .fileExporter(
            isPresented: $viewModel.showExport,
            document: PagiDocument(text: viewModel.text),
            contentType: .plainText,
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

extension ContentView {
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
        @Published var showShareSheet = false
        @Published var showClearNotification = false
        @Published var shouldHideToolbar = false
        @Published var toolbarHeight: Double = .zero
        @Published var isKeyboardVisible = false
        
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
            var height = shouldHideToolbar || isKeyboardVisible ? toolbarHeight + geometry.safeAreaInsets.bottom : 0
            if isiPad {
                height = shouldHideToolbar ? 0 - toolbarHeight + geometry.safeAreaInsets.top : 0
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
        
        func onShowExport() {
            onButtonTap()
            showExport.toggle()
        }
        
        func onShowShareSheet() {
            onButtonTap()
            showShareSheet.toggle()
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
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: ContentView.ViewModel())
    }
}
