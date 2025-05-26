import SwiftUI

public struct FocusCommands: Commands {
    
    @Binding public var focusMode: Bool
    @Binding public var focusType: FocusType
    
    public init(focusMode: Binding<Bool>, focusType: Binding<FocusType>) {
        self._focusMode = focusMode
        self._focusType = focusType
    }
    
    public var body: some Commands {
        CommandMenu("Focus") {
            Toggle(focusMode ? "Disable Focus Mode" : "Enable Focus Mode", isOn: $focusMode)
                .keyboardShortcut("d", modifiers: .command)
            
            Picker("Mode", selection: $focusType) {
                ForEach(FocusType.allCases, id: \.self) { type in
                    Button(type.title) {
                        focusType = type
                    }
                }
            }.pickerStyle(.inline)
            
        }
    }
}
