//
//  Editor.swift
//  Pagi
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct Editor: View {
    @Binding var text: String
    
    @StateObject var viewModel = EditorViewModel()
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            TextEditorView(
                text: $text,
                font: viewModel.fontFile,
                size: CGFloat(viewModel.fontSize),
                isSpellCheckingEnabled: viewModel.isSpellCheckingEnabled
            )
                .id("\(viewModel.fontFile)\(viewModel.fontSize)")
            #else
            TextEditor(text: $viewModel.text)
                .font(.custom(viewModel.fontFile, size: viewModel.fontSize))
                .frame(maxWidth: 650)
                .lineSpacing(8)
                .padding(.vertical, 32)
                .background(Color.background)
                .foregroundColor(.foreground)
            #endif
        }
        .background(Color.background)
        .overlay(
            VStack {
                VStack {
                    
                    // MARK: Word Count
                    HStack {
                        Spacer()
                        
                        if viewModel.wordCount {
                            Text("\(viewModel.words)W")
                                .font(
                                    .custom(viewModel.fontFile, size: 12)
                                        .monospacedDigit()
                                )
                                .foregroundColor(.foregroundLight)
                                .padding(.trailing, 10)
                                .transition(.move(edge: .trailing))
                        }
                    }
                    .padding(.bottom, viewModel.progressBarVisible ? 0 : 5)
                    
                    
                    // MARK: Progress Bar
                    if viewModel.progressBarVisible {
                        ProgressBar(percent: viewModel.percent, color: .accentColor, height: viewModel.isProgressBarExpanded ? 24 : 5)
                            .transition(.move(edge: .bottom))
                            .overlay (
                                VStack {
                                    if viewModel.isProgressBarExpanded {
                                        Label(viewModel.successText, systemImage: "checkmark")
                                            .transition(.offset(x: 0, y: 24))
                                        
                                    }
                                }
                                .font(
                                    .custom(viewModel.fontFile, size: 12)
                                        .monospacedDigit()
                                )
                                .foregroundColor(.background)
                            )
                    }
                }
                .onHover(perform: { hover in
                    withAnimation {
                        viewModel.overlayHover = hover
                    }
                })
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        )
        .onAppear {
            viewModel.calculateWordCount(text)
        }
        .onChange(of: text, perform: { value in
            viewModel.calculateWordCount(text, typing: true)
        })
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(text: .constant("This is a test."))
    }
}
