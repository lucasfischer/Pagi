import SwiftUI

public enum FocusType: String, CaseIterable, Codable {
    case sentence
    case paragraph
    case typeWriter
    
    public var title: LocalizedStringResource {
        switch self {
            case .sentence:
                LocalizedStringResource("Sentence", bundle: .atURL(Bundle.module.bundleURL))
            case .paragraph:
                LocalizedStringResource("Paragraph", bundle: .atURL(Bundle.module.bundleURL))
            case .typeWriter:
                LocalizedStringResource("Typewriter", bundle: .atURL(Bundle.module.bundleURL))
        }
    }
}
