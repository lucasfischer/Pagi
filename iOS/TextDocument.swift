import UIKit

class TextDocument: UIDocument {
    var text: String = ""
    
    override func contents(forType typeName: String) throws -> Any {
        return text.data(using: .utf8) ?? Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        if let data = contents as? Data {
            text = String(data: data, encoding: .utf8) ?? ""
        }
    }
    
    func updateText(_ newText: String) {
        text = newText
        updateChangeCount(.done)
    }
    
}
