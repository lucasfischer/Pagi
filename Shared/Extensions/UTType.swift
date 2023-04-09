//
//  UTType.swift
//  Pagi
//
//  Created by Lucas Fischer on 09.04.23.
//

import UniformTypeIdentifiers

extension UTType {
    static let markdown: UTType = UTType(filenameExtension: "md", conformingTo: .plainText)!
}
