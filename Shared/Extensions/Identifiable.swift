import Foundation

extension String: @retroactive Identifiable {
    public var id: String { self }
}

extension URL: @retroactive Identifiable {
    public var id: String { absoluteString }
}
