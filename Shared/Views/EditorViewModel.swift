//
//  EditorViewModel.swift
//  Pagi
//
//  Created by Lucas Fischer on 18.06.21.
//

import SwiftUI

class EditorViewModel: ObservableObject {
    @Published var words = 0
    
    @AppStorage("wordTarget") var wordTarget = 1500
    @AppStorage("wordCount")  var wordCount = true
    @AppStorage("progressBar") var progressBar = true
    @AppStorage("font") var font = iAFont.duo
    @AppStorage("fontSize") var fontSize = 18
    
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
    
    func calculateWordCount(_ text: String) {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        
        withAnimation {
            self.words = words.count
        }
    }
}
