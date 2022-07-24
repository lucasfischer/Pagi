//
//  GeneralSettingsView.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI

struct GeneralSettingsView: View {
    @AppStorage("wordTarget") private var wordTarget = 1500
    @AppStorage("wordCount") private var wordCount = true
    @AppStorage("progressBar") private var progressBar = true
    @AppStorage("isSpellCheckingEnabled") private var isSpellCheckingEnabled = false
    @AppStorage("focusMode") private var isFocusModeEnabled = false
    @AppStorage("focusType") private var focusType = FocusType.sentence
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            Form {
                
                TextField("Word Target:", value: $wordTarget.animation(.spring()), formatter: formatter)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 144)
                
                Spacer()
                    .frame(height: 16)
                
                Toggle("Show Word Count", isOn: $wordCount.animation(.spring()))
                
                Toggle("Show Progress Bar", isOn: $progressBar.animation(.spring()))
                
                Toggle("Spell Checker", isOn: $isSpellCheckingEnabled)
                
                Spacer()
                    .frame(height: 16)
                
                
                Toggle("Focus Mode", isOn: $isFocusModeEnabled)
                
                Picker("Focus:", selection: $focusType) {
                    ForEach(FocusType.allCases, id: \.self) { type in
                        Button(type.title) {
                            focusType = type
                        }
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 152)
                
            }
            
        }
        .padding()
        .frame(width: 320)
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
