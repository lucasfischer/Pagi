import SwiftUI
import UniformTypeIdentifiers

public struct PagiDocument: FileDocument {
    public var text: String

    public init(text: String = "") {
        self.text = text
    }

    public static let readableContentTypes: [UTType] = [.plainText, .markdown]

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        text = string
    }
    
    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = text.data(using: .utf8)!
        return .init(regularFileWithContents: data)
    }
}
