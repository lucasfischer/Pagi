//
//  ContentView.swift
//  Shared
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("text") private var text = ""
    
    @State private var showExport = false
    @State private var showSettings = false
    @State private var showShareSheet = false
    
    var currentDateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-MM-dd"
        return formatter.string(from: Date())
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                Editor(text: $text)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showSettings.toggle() }) {
                        Label("Settings", systemImage: "gear")
                    }
                    .keyboardShortcut(",", modifiers: .command)
                    .popover(isPresented: $showSettings) {
                        SettingsView()
                            .frame(
                                minWidth: 320,
                                idealWidth: 400,
                                idealHeight: 700,
                                alignment: .top
                            )
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { showShareSheet.toggle() }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: { showExport.toggle() }) {
                            Label("Export", systemImage: "square.and.arrow.up.on.square")
                        }
                    } label: {
                        Button(action: { showExport.toggle() }) {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                    }
                    .disabled(text.isEmpty)
                    .popover(isPresented: $showShareSheet) {
                        ShareSheet(activityItems: [text])
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .navigationViewStyle(.stack)
        .fileExporter(
            isPresented: $showExport,
            document: PagiDocument(text: text),
            contentType: .plainText,
            defaultFilename: currentDateString,
            onCompletion: { _ in }
        )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
