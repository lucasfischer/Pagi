import SwiftUI

public struct FocusCommands: Commands {
    
    @Binding public var focusMode: Bool
    @Binding public var focusType: FocusType
    
    public init(focusMode: Binding<Bool>, focusType: Binding<FocusType>) {
        self._focusMode = focusMode
        self._focusType = focusType
    }
    
    public var body: some Commands {
        CommandMenu(Text("Focus", bundle: .module)) {
            Toggle(isOn: $focusMode) {
                Text(focusMode ? "Disable Focus Mode" : "Enable Focus Mode", bundle: .module)
            }
            .keyboardShortcut("d", modifiers: .command)
            
            Picker(selection: $focusType) {
                ForEach(FocusType.allCases, id: \.self) { type in
                    Button {
                        focusType = type
                    } label: {
                        Text(type.title)
                    }
                }
            } label: {
                Text("Mode", bundle: .module)
            }
            .pickerStyle(.inline)
        }
    }
}
