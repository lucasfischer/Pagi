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
    
    init(text: Binding<String>) {
        #if os(iOS)
        UITextView.appearance().backgroundColor = .clear
        #endif
        
        self._text = text
    }
    
    var progressBarHeight: CGFloat {
        #if os(iOS)
        48
        #else
        24
        #endif
    }
    
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
            ScrollView {
                VStack {
                    TextEditorView(
                        text: $text,
                        font: viewModel.fontFile,
                        size: CGFloat(viewModel.fontSize),
                        isSpellCheckingEnabled: viewModel.isSpellCheckingEnabled
                    )
                        .frame(maxWidth: 650, maxHeight: .infinity)
                        .frame(maxWidth: .infinity)
                        .id("\(viewModel.fontFile)\(viewModel.fontSize)")
                }
                .padding(.bottom, 40)
                .frame(maxHeight: .infinity)
            }
            #endif
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                        ProgressBar(
                            percent: viewModel.percent,
                            color: .accentColor,
                            height: viewModel.isProgressBarExpanded ? progressBarHeight : 5
                        )
                            .transition(.move(edge: .bottom))
                            .overlay (
                                VStack {
                                    if viewModel.isProgressBarExpanded {
                                        Label(viewModel.successText, systemImage: "checkmark")
                                            .transition(.offset(x: 0, y: progressBarHeight))
                                        
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
            .ignoresSafeArea(.all, edges: .bottom)
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
