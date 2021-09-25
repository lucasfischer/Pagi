//
//  Font.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import Foundation

enum iAFont: String, CaseIterable {
    case mono = "Mono"
    case duo = "Duo"
    case quattro = "Quattro"
    
    var fileName: String {
        switch self {
        case .mono:
            return "iAWriterMonoV-Text"
        case .duo:
            return "iAWriterDuoV-Text"
        case .quattro:
            return "iAWriterQuattroV-Text"
        }
    }
}
