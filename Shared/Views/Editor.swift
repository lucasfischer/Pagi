//
//  Editor.swift
//  Pagi
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct Editor: View {
    @Binding var text: String
    @State var words = 0
    
    @AppStorage("wordTarget") private var wordTarget = 1500
    @AppStorage("wordCount") private var wordCount = true
    @AppStorage("progressBar") private var progressBar = true
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("fontSize") private var fontSize = 18
    
    @Environment(\.colorScheme) var colorScheme
    
    var targetReached: Bool {
        words >= wordTarget
    }
    
    var progressBarVisible: Bool {
        progressBar || targetReached
    }
    
    var percent: Float {
        Float(self.words) / Float(wordTarget)
    }
    
    var fontFile: String {
        switch font {
        case .mono:
            return "iAWriterMonoV-Text"
        case .duo:
            return "iAWriterDuoV-Text"
        case .quattro:
            return "iAWriterQuattroV-Text"
        }
    }
    
    func calculateWordCount() {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        
        withAnimation {
            self.words = words.count
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            #if os(macOS)
            TextEditorView(text: $text, font: fontFile, size: CGFloat(fontSize))
                .id("\(fontFile)\(fontSize)")
            #else
            TextEditor(text: $text)
                .font(.custom(fontFile, size: fontSize))
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
                if wordCount {
                    HStack {
                        Spacer()
                        Text("\(words)W")
                            .font(.custom(fontFile, size: 12))
                            .foregroundColor(.foregroundLight)
                    }
                    .padding(.bottom, progressBarVisible ? 0 : 5)
                    .padding(.trailing, 10)
                    .transition(.move(edge: .trailing))
                }
                
                if progressBarVisible {
                    ProgressBar(percent: percent, color: Color.accentColor, height: targetReached ? 24 : 5)
                        .transition(.move(edge: .bottom))
                        .overlay (
                            VStack {
                                if words >= wordTarget {
                                    Label("Word Target Reached", systemImage: "checkmark")
                                        .font(.custom(fontFile, size: 12))
                                        .foregroundColor(.background)
                                        .transition(.offset(x: 0, y: 24))
                                }
                            }
                        )
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
            .onAppear {
                calculateWordCount()
            }
            .onChange(of: text, perform: { value in
                calculateWordCount()
            })
        )
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(text: .constant("This is a test."))
    }
}
