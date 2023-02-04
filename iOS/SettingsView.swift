//
//  SettingsView.swift
//  SettingsView
//
//  Created by Lucas Fischer on 11.09.21.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var preferences = Preferences.shared
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appBundle = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    
    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section("General") {
                        HStack {
                            Text("Word Target")
                            
                            Spacer()
                            
                            TextField(
                                "Word Target",
                                value: $preferences.wordTarget.animation(.spring()),
                                formatter: formatter,
                                prompt: Text("Word Target")
                            )
                                .keyboardType(.numberPad)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.trailing)
                        }
                        
                        Toggle("Word Count", isOn: $preferences.wordCount.animation(.spring()))
                        Toggle("Progress Bar", isOn: $preferences.progressBar.animation(.spring()))
                        Toggle("Spell Checker", isOn: $preferences.isSpellCheckingEnabled)
                        Toggle("Focus Mode", isOn: $preferences.isFocusModeEnabled)
                        Picker("Focus:", selection: $preferences.focusType) {
                            ForEach(FocusType.allCases, id: \.self) { type in
                                Button(type.title) {
                                    preferences.focusType = type
                                }
                            }
                        }
                    }
                    
                    Section("Appearance", content: {
                        Slider(value: $preferences.fontSize, in: 10...40, step: 1) {
                            Text("Font Size (\(preferences.fontSize, specifier: "%.0f")):")
                        } minimumValueLabel: {
                            Image(systemName: "textformat.size.smaller")
                        } maximumValueLabel: {
                            Image(systemName: "textformat.size.larger")
                        }
                        .foregroundColor(.secondary)
                        
                        Picker("Font", selection: $preferences.font) {
                            ForEach(iAFont.allCases, id: \.self) { font in
                                Text(verbatim: font.rawValue)
                            }
                        }
                        
                        Picker("Theme", selection: $preferences.theme) {
                            ForEach(Theme.allCases, id: \.self) { theme in
                                Text(verbatim: theme.rawValue)
                            }
                        }
                    })
                    
                    // MARK: App Version
                    if let appVersion = appVersion, let appBundle = appBundle {
                        HStack {
                            Text("Version")
                            
                            Spacer()
                            
                            Text("\(appVersion) (\(appBundle))")
                                .foregroundColor(.secondary)
                        }
                    }
                    NavigationLink("Acknowlegements") {
                        Form {
                            Link("iA Writer Typeface", destination: URL(string: "https://github.com/iaolo/iA-Fonts")!)
                        }
                        .navigationTitle("Acknowlegements")
                    }
                }
            }
            .tint(.accentColor)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .navigationViewStyle(.stack)
    }
}
