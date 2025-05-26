import UniformTypeIdentifiers

public enum FileType: String, CaseIterable {
    
    case text = "text"
    case markdown = "markdown"
    
    public var type: UTType {
        switch self {
        case .text:
            return .plainText
        case .markdown:
            return .markdown
        }
    }
    
    public var name: String {
        switch self {
        case .text:
            return "Plain Text"
        case .markdown:
            return "Markdown"
        }
    }
    
}
