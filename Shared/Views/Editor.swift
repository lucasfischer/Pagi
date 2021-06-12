//
//  Editor.swift
//  Pagi
//
//  Created by Lucas Fischer on 19.03.21.
//

import SwiftUI

struct Editor: View {
    @Binding var text: String
    @AppStorage("wordTarget") private var wordTarget = 1500
    @AppStorage("wordCount") private var wordCount = true
    @AppStorage("progressBar") private var progressBar = true
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("fontSize") private var fontSize = 18
    @Environment(\.colorScheme) var colorScheme
    
    var words: Int {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        
        return words.count
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
                    .padding(.bottom, progressBar ? 0 : 5)
                    .padding(.trailing, 10)
                    .transition(AnyTransition.move(edge: .trailing).animation(.spring()))
                    .animation(.spring())
                }
                
                if progressBar {
                    ProgressBar(percent: percent, color: Color.accentColor)
                        .transition(AnyTransition.move(edge: .bottom).animation(.spring()))
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        )
    }
}

struct Editor_Previews: PreviewProvider {
    static var previews: some View {
        Editor(text: .constant("This is a test."))
    }
}
