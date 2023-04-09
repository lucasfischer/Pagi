//
//  FileType.swift
//  Pagi
//
//  Created by Lucas Fischer on 09.04.23.
//

import UniformTypeIdentifiers

enum FileType: String, CaseIterable {
    
    case text = "text"
    case markdown = "markdown"
    
    var type: UTType {
        switch self {
        case .text:
            return .plainText
        case .markdown:
            return .markdown
        }
    }
    
    var name: String {
        switch self {
        case .text:
            return "Plain Text"
        case .markdown:
            return "Markdown"
        }
    }
    
}
