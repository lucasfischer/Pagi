import SwiftUI

public enum FocusType: String, CaseIterable, Codable {
    case sentence
    case paragraph
    case typeWriter
    
    public var title: LocalizedStringKey {
        switch self {
        case .sentence:
            return "Sentence"
        case .paragraph:
            return "Paragraph"
        case .typeWriter:
            return "Typewriter"
        }
    }
}
