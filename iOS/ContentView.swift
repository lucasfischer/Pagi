//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: ViewModel
    
    var body: some View {
        
        Editor(text: $viewModel.text, shouldHideToolbar: $viewModel.shouldHideToolbar)
            .ignoresSafeArea(viewModel.isKeyboardVisible ? .container : .all, edges: [.bottom])
            .ignoresSafeArea(.all, edges: .top)
            .id(viewModel.lastOpenedDate)
            .animation(.default, value: viewModel.shouldHideToolbar)
            .statusBarHidden(viewModel.shouldHideToolbar)
            .setPersistentSystemOverlays(viewModel.shouldHideToolbar ? .hidden : .automatic)
            .overlay(alignment: .top) {
                HStack {
                    Button(action: { viewModel.showSettings.toggle() }) {
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
                    
                    Menu {
                        Button(action: { viewModel.showShareSheet.toggle() }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        Button(action: { viewModel.showExport.toggle() }) {
                            Label("Export", systemImage: "square.and.arrow.up.on.square")
                        }
                    } label: {
                        Button(action: { viewModel.showExport.toggle() }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                                .labelStyle(.iconOnly)
                                .font(.title2)
                        }
                    }
                    .disabled(viewModel.text.isEmpty)
                    .popover(isPresented: $viewModel.showShareSheet) {
                        ShareSheet(activityItems: [viewModel.text])
                    }
                    
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Material.thin)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.black.opacity(0.1))
                }
                .offset(x: 0, y: viewModel.shouldHideToolbar ? 0 - viewModel.toolbarHeight : 0)
                .animation(.spring(), value: viewModel.shouldHideToolbar)
                .readSize { height in
                    viewModel.toolbarHeight = height
                }
            }
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
                    Button("Keep") {
                        viewModel.showClearNotification = false
                    }
                    Button("Clear") {
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
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidShowNotification)) { data in
                viewModel.isKeyboardVisible = true
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.keyboardDidHideNotification)) { data in
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
        @Published var showSettings = false
        @Published var showShareSheet = false
        @Published var showClearNotification = false
        @Published var shouldHideToolbar = false
        @Published var toolbarHeight: Double = .zero
        @Published var isKeyboardVisible = false
        
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
                showClearNotification = true
            }
            else {
                showClearNotification = false
            }
        }
        
        func onTextUpdate(_ text: String) {
            lastOpenedDate = dateFormatter.string(from: Date())
            isFileExported = false
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
