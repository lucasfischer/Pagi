import SwiftUI

public struct FontCommands: Commands {
    @Binding public var font: iAFont
    @Binding public var fontSize: Double
    
    public init(font: Binding<iAFont>, fontSize: Binding<Double>) {
        self._font = font
        self._fontSize = fontSize
    }
    
    public var body: some Commands {
        CommandMenu(Text("Font", bundle: .module)) {
            Picker(selection: $font) {
                ForEach(iAFont.allCases, id: \.self) { font in
                    Text(verbatim: font.rawValue)
                }
            } label: {
                Text("Font", bundle: .module)
            }
            
            Divider()
            
            Button {
                if fontSize < 40 {
                    fontSize += 1
                }
            } label: {
                Text("Increase Size", bundle: .module)
            }
            .keyboardShortcut("+", modifiers: .command)
            
            Button {
                fontSize = 18
            } label: {
                Text("Default Size", bundle: .module)
            }
            .keyboardShortcut("0", modifiers: .command)
            
            Button {
                if fontSize > 10 {
                    fontSize -= 1
                }
            } label: {
                Text("Decrease Size", bundle: .module)
            }
            .keyboardShortcut("-", modifiers: .command)
        }
    }
}
