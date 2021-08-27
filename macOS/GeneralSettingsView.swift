//
//  GeneralSettingsView.swift
//  Pagi
//
//  Created by Lucas Fischer on 05.06.21.
//

import SwiftUI
import Sparkle

struct GeneralSettingsView: View {
    @AppStorage("wordTarget") private var wordTarget = 1500
    @AppStorage("theme") private var theme = Theme.system
    @AppStorage("font") private var font = iAFont.duo
    @AppStorage("wordCount") private var wordCount = true
    @AppStorage("progressBar") private var progressBar = true
    @AppStorage("isSpellCheckingEnabled") private var isSpellCheckingEnabled = false
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    private func checkForUpdates() {
        guard let updater = SUUpdater.shared() else { return }
        updater.checkForUpdates(self)
    }
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            
            // Word Target
            HStack {
                Text("Word Target:")
                    .frame(width: 128, alignment: .trailing)
                
                TextField("Word Target", value: $wordTarget.animation(.spring()), formatter: formatter)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 80)
            }
            
            // Word Count
            HStack {
                Text("Show Word Count:")
                    .frame(width: 128, alignment: .trailing)
                
                Toggle("", isOn: $wordCount.animation(.spring()))
            }
            
            // Progress Bar
            HStack {
                Text("Show Progress Bar:")
                    .frame(width: 128, alignment: .trailing)
                
                Toggle("", isOn: $progressBar.animation(.spring()))
            }
            
            // Spell Checker
            HStack {
                Text("Spell Checker:")
                    .frame(width: 128, alignment: .trailing)
                
                Toggle("", isOn: $isSpellCheckingEnabled)
            }
            
            // Font
            HStack {
                Text("Font:")
                    .frame(width: 128, alignment: .trailing)
                
                Picker("", selection: $font) {
                    ForEach(iAFont.allCases, id: \.self) { font in
                        Text("\(font.rawValue)")
                    }
                }
                .offset(x: -10)
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 160)
            }
            
            // Theme
            HStack {
                Text("Theme:")
                    .frame(width: 128, alignment: .trailing)
                
                Picker("", selection: $theme) {
                    ForEach(Theme.allCases, id: \.self) { theme in
                        Text("\(theme.rawValue)")
                    }
                }
                .offset(x: -10)
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 160)
            }
            
            HStack {
                // MARK: App Version
                if let appVersion = appVersion, let appBundle = appBundle {
                    Text("Version: \(appVersion) (\(appBundle))")
                        .frame(width: 128, alignment: .trailing)
                }
                
                Button("Check For Updates", action: checkForUpdates)
            }
        }
        .padding()
    }
}

struct GeneralSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        GeneralSettingsView()
    }
}
