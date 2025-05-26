import SwiftUI

public struct FontCommands: Commands {
    @Binding public var font: iAFont
    @Binding public var fontSize: Double
    
    public init(font: Binding<iAFont>, fontSize: Binding<Double>) {
        self._font = font
        self._fontSize = fontSize
    }
    
    public var body: some Commands {
        CommandMenu("Font") {
            Picker("Font", selection: $font) {
                ForEach(iAFont.allCases, id: \.self) { font in
                    Text(verbatim: font.rawValue)
                }
            }
            
            Divider()
            
            Button("Increase Size") {
                if fontSize < 40 {
                    fontSize += 1
                }
            }
            .keyboardShortcut("+", modifiers: .command)
            
            Button("Default Size") {
                fontSize = 18
            }
            .keyboardShortcut("0", modifiers: .command)
            
            Button("Decrease Size") {
                if fontSize > 10 {
                    fontSize -= 1
                }
            }
            .keyboardShortcut("-", modifiers: .command)
        }
    }
}
