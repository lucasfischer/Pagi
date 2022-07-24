//
//  FocusType.swift
//  Pagi
//
//  Created by Lucas Fischer on 24.07.22.
//

import SwiftUI

enum FocusType: String, CaseIterable, Codable {
    case sentence
    case paragraph
    case typeWriter
    
    var title: LocalizedStringKey {
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
