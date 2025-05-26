import SwiftUI
import PagiKit

struct GeneralSettingsView: View {
    @StateObject private var preferences = Preferences.shared
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Form {
                
                TextField("Word Target:", value: $preferences.wordTarget.animation(.spring()), formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 144)
                
                Spacer()
                    .frame(height: 16)
                
                Toggle("Show Word Count", isOn: $preferences.wordCount.animation(.spring()))
                
                Toggle("Show Progress Bar", isOn: $preferences.progressBar.animation(.spring()))
                
                Toggle("Spell Checker", isOn: $preferences.isSpellCheckingEnabled)
                
                Spacer()
                    .frame(height: 16)
                
                
                Toggle("Focus Mode", isOn: $preferences.isFocusModeEnabled)
                
                Picker("Focus:", selection: $preferences.focusType) {
                    ForEach(FocusType.allCases, id: \.self) { type in
                        Button {
                            preferences.focusType = type
                        } label: {
                            Text(type.title)
                        }
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 152)
                
            }
            
        }
        .padding()
        .frame(width: 400)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
