//
//  EditorViewModel.swift
//  Pagi
//
//  Created by Lucas Fischer on 18.06.21.
//

import SwiftUI

class EditorViewModel: ObservableObject {
    @Published var words = 0
    @Published var overlayHover = false
    
    @AppStorage("wordTarget") var wordTarget = 1500
    @AppStorage("wordCount")  var wordCount = true
    @AppStorage("progressBar") var progressBar = true
    @AppStorage("font") var font = iAFont.duo
    @AppStorage("fontSize") var fontSize = 18
    @AppStorage("focusMode") var focusMode = false
    @AppStorage("isSpellCheckingEnabled") var isSpellCheckingEnabled = false
    
    #if os(iOS)
    private let isiOS = true
    #else
    private let isiOS = false
    #endif
    
    let timer = Timer()
    
    var targetReached: Bool {
        words >= wordTarget
    }
    
    var isProgressBarExpanded: Bool {
        targetReached && (words <= (wordTarget + 10) || overlayHover || isiOS)
    }
    
    var progressBarVisible: Bool {
        progressBar || targetReached
    }
    
    var percent: Float {
        Float(self.words) / Float(wordTarget)
    }
    
    var successText: LocalizedStringKey {
        if let endDuration = timer.endDuration {
            return "\(words) words in \(endDuration)"
        } else {
            return "Word Target Reached"
        }
    }
    
    func calculateWordCount(_ text: String, typing: Bool = false) {
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let components = text.components(separatedBy: chararacterSet)
        let words = components.filter { !$0.isEmpty }
        
        withAnimation {
            self.words = words.count
        }
        
        if typing && !timer.isRunning && !timer.isEnded {
            timer.start()
        }
        else if typing && timer.isRunning && targetReached {
            timer.stop()
        }
        timer.typing()
    }
}
