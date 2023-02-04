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
    
    let preferences = Preferences.shared
    
    #if os(iOS)
    private let isiOS = true
    #else
    private let isiOS = false
    #endif
    
    let timer = Timer()
    
    var targetReached: Bool {
        words >= preferences.wordTarget
    }
    
    var isProgressBarExpanded: Bool {
        targetReached && (words <= (preferences.wordTarget + 10) || overlayHover || isiOS)
    }
    
    var progressBarVisible: Bool {
        preferences.progressBar || targetReached
    }
    
    var percent: Float {
        Float(self.words) / Float(preferences.wordTarget)
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
        
        self.words = words.count
        
        if typing && !timer.isRunning && !timer.isEnded {
            timer.start()
        }
        else if typing && timer.isRunning && targetReached {
            timer.stop()
        }
        timer.typing()
    }
}
