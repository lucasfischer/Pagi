//
//  ViewCommands.swift
//  Pagi (iOS)
//
//  Created by Lucas Fischer on 10.01.23.
//

import SwiftUI

struct ViewCommands: Commands {
    @ObservedObject var viewModel: EditorView.ViewModel
    
    @Binding var wordCount: Bool
    @Binding var progressBar: Bool
    
    var body: some Commands {
        CommandMenu("View") {
            Button(wordCount ? "Hide Word Count" : "Show Word Count") {
                withAnimation(.spring()) {
                    wordCount.toggle()
                }
            }
            .keyboardShortcut("E", modifiers: .command)
            
            Button(wordCount ? "Hide Progress Bar" : "Show Progress Bar") {
                withAnimation(.spring()) {
                    progressBar.toggle()
                }
            }
            .keyboardShortcut("r", modifiers: .command)
            

            Button("Show Settings") {
                viewModel.showSettings = true
            }
            .keyboardShortcut(",", modifiers: .command)

            Button("Export") {
                viewModel.showExport.toggle()
            }
            .keyboardShortcut("s", modifiers: .command)
            
            Button("Share") {
                viewModel.onShowShareSheet()
            }
            .keyboardShortcut("s", modifiers: [.shift, .command])
        }
    }
}

