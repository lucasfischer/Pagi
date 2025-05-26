import SwiftUI

@MainActor
public class EditorViewModel: ObservableObject {
    @Published public var words = 0
    @Published public var overlayHover = false
    @Published public var shouldHideToolbar = false
    
    let preferences = Preferences.shared
    
    public init() {}
    
    #if os(iOS)
    private let isiOS = true
    #else
    private let isiOS = false
    #endif
    
    public let timer = Timer()
    
    public var targetReached: Bool {
        words >= preferences.wordTarget
    }
    
    public var isProgressBarExpanded: Bool {
        targetReached && (words <= (preferences.wordTarget + 10) || overlayHover || isiOS)
    }
    
    public var progressBarVisible: Bool {
        preferences.progressBar || targetReached
    }
    
    public var percent: Float {
        Float(self.words) / Float(preferences.wordTarget)
    }
    
    public var successText: LocalizedStringKey {
        if let endDuration = timer.endDuration {
            return "\(words) words in \(endDuration)"
        } else {
            return "Word Target Reached"
        }
    }
    
    public func calculateWordCount(_ text: String, typing: Bool = false) {
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
    
    public func resetTimer() {
        timer.reset()
    }
}
