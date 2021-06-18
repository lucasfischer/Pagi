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
            TextEditorView(text: $text, font: viewModel.fontFile, size: CGFloat(viewModel.fontSize))
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
                if viewModel.wordCount {
                    HStack {
                        Spacer()
                        Text("\(viewModel.words)W")
                            .font(.custom(viewModel.fontFile, size: 12))
                            .foregroundColor(.foregroundLight)
                    }
                    .padding(.bottom, viewModel.progressBarVisible ? 0 : 5)
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                }
                
                if viewModel.progressBarVisible {
                    ProgressBar(percent: viewModel.percent, color: Color.accentColor, height: viewModel.targetReached ? 24 : 5)
                        .transition(.move(edge: .bottom))
                        .overlay (
                            VStack {
                                if viewModel.words >= viewModel.wordTarget {
                                    Label("Word Target Reached", systemImage: "checkmark")
                                        .font(.custom(viewModel.fontFile, size: 12))
                                        .foregroundColor(.background)
                                        .transition(.offset(x: 0, y: 24))
                                }
                            }
                        )
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                viewModel.calculateWordCount(text)
            }
            .onChange(of: text, perform: { value in
                viewModel.calculateWordCount(text)
            })
        )
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(text: .constant("This is a test."))
    }
}
